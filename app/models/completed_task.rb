class CompletedTask < ActiveRecord::Base
  CORRECT_POINTS = 100
  
  attr_readonly :task_id
  attr_protected :updated_at, :answer_id, :points_awarded, :award_points
  attr_accessible :status_id, :task_id, :session_id, :submitted_answer_id, :enrollment_id
  attr_accessor :award_points, :correct_answer, :points_remaining
  
  belongs_to :user
  belongs_to :task
  belongs_to :enrollment
  has_one :topic, through: :task
  belongs_to :submitted_answer, dependent: :destroy
  belongs_to :chosen_answer, class_name: "Answer"
  has_one :section, through: :task
  has_one :path, through: :section
  
  validates :user_id, presence: true
  validates :task_id, presence: true
  validates :enrollment_id, presence: true
  validates_uniqueness_of :task_id, scope: :user_id
  validates :status_id, presence: true
  
  after_initialize do
    self.created_at ||= Time.now()
  end

  before_create do
    self.status_id = Answer::INCOMPLETE
  end
  
  after_save do
    if correct? && award_points
      user.award_points(self, self.points_awarded)
    end
    self.award_points = false
  end
  
  def reviewed?
    return true if submitted_answer.nil?
    return submitted_answer.reviewed?
  end
  def incomplete?() status_id == Answer::INCOMPLETE end
  def correct?() status_id == Answer::CORRECT end
  def incorrect?() status_id == Answer::INCORRECT end
    
  def self.find_or_create(user, task, enrollment, session_id)
    enrollment = user.enroll!(task.path) unless enrollment

    unless ct = where(user_id: user.id, task_id: task.id).first
      ct = new(task_id: task.id, enrollment_id: enrollment.id, session_id: session_id)
      ct.user_id = user.id
      ct.save!
      ct.reload
    end

    return ct
  end
    
  def complete_core_task!(supplied_answer, points)
    if status_id != Answer::INCOMPLETE
      raise "Already answered: #{self.to_yaml}" 
    end
    
    time_limit = created_at + task.time_allowed
    if points > 0
      if time_limit < Time.now
        points = 0 
      elsif (points - points_remaining).abs > 6
        points = points_remaining
      end
    end

    self.answer = supplied_answer
    matched_answer = nil
    answers = Answer.cached_find_by_task_id(task_id)
    answers.each do |a|
      if a.is_correct
        self.correct_answer = a.content
      end
      
      if a.match?(answer)
        matched_answer = a
      end
    end
    
    if matched_answer and matched_answer.is_correct?
      self.status_id = Answer::CORRECT
      self.points_awarded = points
      self.award_points = true
    else
      self.status_id = Answer::INCORRECT
      self.points_awarded = 0
    end
    save!
  end

  def points_remaining
    self.created_at ||= Time.now
    time_remaining = (self.created_at + self.task.time_allowed) - Time.now
    points = ((time_remaining / 45) * 100).to_i
    points = 100 if points > 100
    points = 0 unless points > 0
    return points
  end
end
