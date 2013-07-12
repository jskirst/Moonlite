class Task < ActiveRecord::Base
  CREATOR_AWARD_POINTS = 20
  CREATOR_PENALTY_POINTS = 20
  
  CREATIVE  = 0
  EXACT     = 1
  MULTIPLE  = 2
  CHECKIN   = 3
  TYPES = { EXACT => "Exact", MULTIPLE => "Multiple Choice", CREATIVE => "Creative Response", CHECKIN => "Task" }
  
  # Creative Subtypes
  TEXT        = 100
  IMAGE       = 101
  YOUTUBE     = 102
  LONG_EXACT  = 103
  SUBTYPES = { TEXT => "Text response", IMAGE => "Image upload", YOUTUBE => "Youtube video", LONG_EXACT => "Long Exact" }
  
  attr_accessor :source, :answer_content, :stored_resource_id, :answer_new_1, :answer_new_2, :answer_new_3, :answer_new_4, :topic_name
  attr_protected :section_id, :archived_at
  attr_accessible :question,
    :answer_type, 
    :answer_sub_type,
    :answer_content,
    :creator_id,
    :path_id,
    :source,
    :template,
    :position,
    :reviewed_at,
    :resource,
    :resource_title,
    :quoted_text,
    :topic_id, :topic_name
  
  belongs_to :section
  belongs_to :creator, class_name: "User"
  belongs_to :topic
  has_one :path, through: :section
  has_many :completed_tasks
  has_many :answers
  has_many :comments, dependent: :destroy
  has_many :submitted_answers, dependent: :destroy, limit: 10
  has_many :stored_resources, as: :owner
  has_many :comments, as: :owner
  has_many :task_issues
  has_many :topics
  
  validates :question, length: { within: 1..1000 }
  validates_presence_of :section_id
  validates_presence_of :creator_id
  validates_presence_of :path_id
  validates :answer_type, inclusion: { in: [0, 1, 2, 3] }
  validates :answer_sub_type, inclusion: { in: [100, 101, 102] }, allow_nil: true
  validate :has_answers
  
  before_save do
    self.template = nil if template.blank?
    self.quoted_text = nil if quoted_text.blank?
    
    unless topic_name.blank?
      t = Topic.where("topics.name ILIKE ?", topic_name).first
      t = Topic.create!(name: topic_name, path_id: path.id) unless t
      self.topic_id = t.id
    end
  end
  
  after_create do
    unless answer_content.nil?
      answer_content.each do |a|
        answers.create!(content: a[:content], is_correct: a[:is_correct]) unless a[:content].blank?
      end
    end
    creator.enroll!(path) unless creator.enrolled?(path)
    creator.award_points(self, CREATOR_AWARD_POINTS)
  end
  
  after_save :flush_cache
  before_destroy :flush_cache
  
  def has_answers
    return true unless answer_content
    if multiple_choice? and answer_content.size < 2
      errors[:base] << "You must have at least two answers."
    elsif exact? and answer_content.size < 1
      errors[:base] << "You must have at least one answer."
    end
  end
  
  def update_answers(params)
    errors = []
    params.each do |key,value|
      if key.include?("answer_new_")
        unless value.blank?
          a = answers.new(content: value)
          a.is_correct =  multiple_choice? ? false : true
          a.save!
        end
      elsif key.include?("answer_")
        answer = answers.find(key.gsub("answer_",""))
        if value.blank?
          answer.destroy
        elsif answer.content != value
          answer.content = value
          errors += answer.errors.full_messages unless answer.save
        end
      end
    end
    return errors
  end
  
  def correct_answer() answers.find_by_is_correct(true) end
  def total_answers() total_answers = answers.sum(:answer_count) end
  
  def core?() exact? or multiple_choice? end
  def creative?() creative_response? end
    
  def creative_response?() answer_type == CREATIVE end
  def task?() answer_type == CHECKIN end
  def exact?() answer_type == EXACT end
  def multiple_choice?() answer_type == MULTIPLE end
  def text?() creative_response? and answer_sub_type == TEXT end
  def image?() creative_response? and answer_sub_type == IMAGE end
  def youtube?() creative_response? and answer_sub_type == YOUTUBE end
  def long_exact?() creative_response? and answer_sub_type == LONG_EXACT end
    
  def caption_allowed?() image? or youtube? or task? end
    
  def language
    return "html" if template.blank? or template.downcase.include?("<html")
    return "ruby" if template.include?("#ruby")
    return "php" if template.include?("//php")
    return "html"
  end
  
  # Cached methods
  
  def self.cached_find(id)
    Rails.cache.fetch([self.to_s, id]){ where(id: id).joins(:section).select("tasks.*, sections.path_id as path_id").first }
  end
  
  def flush_cache
    Rails.cache.delete([self.class.name, self.id])
  end
  
  private
  
  def answers_to_array() answers.to_a.collect { |a| a.content } end
end
