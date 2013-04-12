class Task < ActiveRecord::Base
  CREATOR_AWARD_POINTS = 20
  CREATOR_PENALTY_POINTS = 40
  
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
  
  attr_readonly :section_id
  attr_accessor :source, :answer_content, :stored_resource_id, :answer1, :answer2, :answer3, :answer4
  attr_accessible :question,
    :answer_type, 
    :answer_sub_type,
    :answer_content,
    :creator_id,
    :source,
    :template,
    :position,
    :reviewed_at
  
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
  validates :answer_type, inclusion: { in: [0, 1, 2, 3] }
  validates :answer_sub_type, inclusion: { in: [100, 101, 102] }, allow_nil: true
  
  after_create do
    if exact? or multiple_choice?
      answer_content.each do |a|
        answers.create!(content: a[:content], is_correct: a[:is_correct]) unless a[:content].blank?
      end
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
    
  def exact?() answer_type == EXACT end
  def multiple_choice?() answer_type == MULTIPLE end
  def creative_response?() answer_type == CREATIVE end
  def task?() answer_type == CHECKIN end
    
  def text?() creative_response? and answer_sub_type == TEXT end
  def image?() creative_response? and answer_sub_type == IMAGE end
  def youtube?() creative_response? and answer_sub_type == YOUTUBE end
  def long_exact?() creative_response? and answer_sub_type == LONG_EXACT end
    
  def caption_allowed?() image? or youtube? or task? end
  
  private
  
  def answers_to_array() answers.to_a.collect { |a| a.content } end
end
