class Task < ActiveRecord::Base
  CREATOR_AWARD_POINTS = 20
  CREATOR_PENALTY_POINTS = 40
  
  CREATIVE  = 0
  FIB       = 1
  MULTIPLE  = 2
  CHECKIN   = 3
  TYPES = { CREATIVE => "Creative Response", MULTIPLE => "Arena", CHECKIN => "Task" }
  
  # Creative Subtypes
  TEXT      = 100
  IMAGE     = 101
  YOUTUBE   = 102
  SUBTYPES = { TEXT => "Text response", IMAGE => "Image upload", YOUTUBE => "Youtube video" }
  
  # Challenge Subtypes
  CHECKIN_CONFIRM   = 200
  CHECKIN_IMAGE     = 201
  CHECKIN_TEXT      = 201
  CHECKIN_LINK      = 201
  
  attr_readonly :section_id
  attr_accessor :answer_content, 
    :source, 
    :answer1, 
    :answer2, 
    :answer3, 
    :answer4,
    :stored_resource_id
  attr_accessible :question,
    :points,
    :position, 
    :answer_type, 
    :answer_sub_type,
    :disable_time_limit,
    :time_limit,
    :answer_content,
    :creator_id,
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
  validates :points, presence: true, numericality: { less_than: 51 }
  validates_presence_of :section_id
  validates_presence_of :creator_id
  
  before_validation { self.points = 10 if self.points.to_i == 0 }
  before_create { self.position = get_next_position_for_section }
  before_save do
    if self.answer_type == 0
      self.disable_time_limit = true
    else
      self.answer_sub_type = nil
    end
  end
  after_create do
    if answer_type == 2
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
  def is_challenge_question?() self.answer_type == 0 || self.answer_type == 3 end
  
  private
    def get_next_position_for_section
      return section.tasks.last.position + 1 unless section.tasks.empty?
      return 1
    end
    
    def answers_to_array() answers.to_a.collect { |a| a.content } end
end
