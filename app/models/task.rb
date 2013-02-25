class Task < ActiveRecord::Base
  CREATOR_AWARD_POINTS = 20
  CREATOR_PENALTY_POINTS = 40
  
  CREATIVE  = 0
  FIB       = 1
  MULTIPLE  = 2
  CHECKIN   = 3
  TYPES = { MULTIPLE => "Multiple Choice", CREATIVE => "Creative Response", CHECKIN => "Task" }
  
  # Creative Subtypes
  TEXT      = 100
  IMAGE     = 101
  YOUTUBE   = 102
  SUBTYPES = { TEXT => "Text response", IMAGE => "Image upload", YOUTUBE => "Youtube video" }
  
  # Checkin URL's allowed
  WILDCARD_URL = 0
  GITHUB_URL   = 1
  
  URL_TEMPLATES = {
    WILDCARD_URL  => /^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$/i, 
    GITHUB_URL    => /^(https:\/\/github\.com\/)([\/\w \.-]*)*\/?$/i
  }
  
  URL_TEMPLATE_NAMES = {
    WILDCARD_URL  => "Any valid website",
    GITHUB_URL    => "GitHub"
  }
  
  attr_readonly :section_id
  attr_accessor :source, :answer_content, :stored_resource_id, :answer1, :answer2, :answer3, :answer4
  attr_accessible :question,
    :answer_type, 
    :answer_sub_type,
    :answer_content,
    :creator_id,
    :url_type,
    :url_template,
    :source
  
  belongs_to :section
  belongs_to :creator, class_name: "User"
  has_one :path, through: :section
  has_many :completed_tasks
  has_many :answers
  has_many :comments, dependent: :destroy
  has_many :submitted_answers, dependent: :destroy, limit: 10
  has_many :stored_resources, as: :owner
  has_many :comments, as: :owner
  has_many :task_issues
  
  validates :question, length: { within: 1..1000 }
  validates_presence_of :section_id
  validates_presence_of :creator_id
  validates_presence_of :url_template
  validates :answer_type, inclusion: { in: [0, 1, 2, 3] }
  validates :answer_sub_type, inclusion: { in: [100, 101, 102] }, allow_nil: true
  
  before_validation { self.url_template = URL_TEMPLATES[url_type.to_i] if task? and url_template.blank? }
  
  after_create do
    if multiple_choice?
      answer_content.each do |a|
        answers.create!(content: a[:content], is_correct: a[:is_correct]) unless a[:content].blank?
      end
      PhrasePairing.create_phrase_pairings(answers_to_array)
    end
    creator.award_points(self, CREATOR_AWARD_POINTS)
  end
  
  def update_answers(params)
    errors = []
    params.each do |key,value| 
      if key.include?("answer_")
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
    
  def multiple_choice?() answer_type == MULTIPLE end
  def creative_response?() answer_type == CREATIVE end
  def task?() answer_type == CHECKIN end
    
  def text?() answer_sub_type == TEXT end
  def image?() answer_sub_type == IMAGE end
  def youtube?() answer_sub_type == YOUTUBE end
    
  def image_allowed?() url_type == WILDCARD_URL end
  def caption_allowed?() image? or youtube? or task? end
  
  private
  
  def answers_to_array() answers.to_a.collect { |a| a.content } end
end
