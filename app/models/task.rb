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
  SUBTYPES = { TEXT => "Text response", IMAGE => "Image upload", YOUTUBE => "YouTube video", LONG_EXACT => "Long Exact" }
  
  # Time limits
  ONE         = 60
  TWO         = 120
  THREE       = 180
  FOUR        = 240
  FIVE        = 300
  TEN         = 600
  FIFTEEN     = 900
  TWENTY      = 1200
  TWENTYFIVE  = 1500
  THIRTY      = 1800
  THIRTYFIVE  = 2100
  FORTY       = 2400
  FORTYFIVE   = 2700
  FIFTY       = 3000
  FIFTYFIVE   = 3300
  SIXTY       = 3600
  TIME_LIMIT  = { ONE => "1 minute", TWO => "2 minutes", THREE => "3 minutes", FOUR => "4 minutes", FIVE => "5 minutes", TEN => "10 minutes", FIFTEEN => "15 minutes", TWENTY => "20 minutes", TWENTYFIVE => "25 minutes", THIRTY => "30 minutes", THIRTYFIVE => "35 minutes", FORTY => "40 minutes", FORTYFIVE => "45 minutes", FIFTY => "50 minutes", FIFTYFIVE => "55 minutes", SIXTY => "60 minutes" }
  
  EASY = 1
  MEDIUM = 1.25
  HARD = 1.5
  EXPERT = 1.75
  DIFFICULTY_TYPES = { EASY => "Easy", MEDIUM => "Medium", HARD => "Hard", EXPERT => "Expert" }
  
  attr_accessor :source, :answer_content, :stored_resource_id, :answer_new_1, :answer_new_2, :answer_new_3, :answer_new_4, :exact1, :topic_name
  attr_protected :archived_at
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
    :topic_id, :topic_name,
    :time_limit,
    :difficulty,
    :topic,
    :section_id,
    :time_limit,
    :answer_new_1, 
    :answer_new_2, 
    :answer_new_3, 
    :answer_new_4,
    :exact1
  
  belongs_to :section
  belongs_to :creator, class_name: "User"
  belongs_to :topic
  belongs_to :path
  has_many :completed_tasks
  has_many :answers
  has_many :comments
  has_many :submitted_answers
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
      t = Topic.where("topics.name ILIKE ? and topics.path_id = ?", topic_name, self.path_id).first
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
  
  def correct_answer() answers.where(is_correct: true).first end
  def total_answers() total_answers = answers.sum(:answer_count) end
  
  def core?() exact? or multiple_choice? end
  def creative?() creative_response? end
    
  def creative_response?() answer_type == CREATIVE end
  def task?() checkin? end
  def checkin?() answer_type == CHECKIN end
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
  
  def to_json
    { 
      question: self.question,
      answer_type: self.answer_type,
      answer_sub_type: self.answer_sub_type,
      template: self.template,
      source_title: self.resource_title,
      source_link: self.resource,
      quoted_text: self.quoted_text,
      time_limit: self.time_limit,
      topic: self.topic.try(&:name),
      answers: self.answers.collect{ |a| { is_correct: a.is_correct, content: a.content } }
    }
  end
  
  def desc(attribute)
    case attribute
    when :difficulty
      if self.difficulty < 1.25
        "Easy"
      elsif self.difficulty < 1.5
        "Medium"
      elsif self.difficulty < 1.75
        "Hard"
      else
        "Expert"
      end
    end
  end
  
  def delay
    question = self.question.to_s
    quoted = self.quoted_text.to_s
    answers = answers_to_array.join 
    q_length = (question + quoted + answers).length.to_f
    # The character_mult is calculated according the speed at which the average American adult reads
    character_mult = 36 
    delay_time = q_length * character_mult
    if delay_time > 3500
      return 3500
    else
      return delay_time.round(3)
    end
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
