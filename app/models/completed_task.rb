class CompletedTask < ActiveRecord::Base
  CORRECT_POINTS = 100
  
  attr_readonly :task_id
  attr_protected :updated_at, :answer_id, :points_awarded, :award_points
  attr_accessible :status_id, :task_id, :session_id, :submitted_answer_id, :enrollment_id
  attr_accessor :award_points, :correct_answer
  
  belongs_to :user
  belongs_to :task
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
    
  def self.find_or_create(user_id, task_id, session_id = nil)
    enrollment_record = Path.joins("INNER JOIN sections on sections.path_id=paths.id")
      .joins("INNER JOIN tasks on tasks.section_id=sections.id and tasks.id=#{task_id.to_s}")
      .joins("LEFT JOIN enrollments on enrollments.path_id=paths.id and enrollments.user_id=#{user_id.to_i}")
      .select("paths.id as path_id, enrollments.id as enrollment_id")
      .first
    unless enrollment_id = enrollment_record.enrollment_id
      enrollment = Enrollment.new
      enrollment.user_id = user_id
      enrollment.path_id = enrollment_record.path_id
      enrollment.save!
      enrollment_id = enrollment.id
    end
    
    ct = find_by_user_id_and_task_id(user_id, task_id)
    unless ct
      ct = new(task_id: task_id, enrollment_id: enrollment_id, session_id: session_id)
      ct.user_id = user_id
      ct.save!
    end
    return ct
  end
    
  def complete_core_task!(supplied_answer, points)
    if status_id != Answer::INCOMPLETE
      raise "Already answered"
    elsif created_at <= 60.seconds.ago and points.to_i > 0
      raise "Out of time"
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
end
