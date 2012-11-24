class CompletedTask < ActiveRecord::Base
  attr_accessible :updated_at, :task_id, :answer_id, :submitted_answer_id, :status_id, :points_awarded
  
  belongs_to :user
  belongs_to :task
  belongs_to :submitted_answer, dependent: :destroy
  belongs_to :chosen_answer, class_name: "Answer"
  has_one :section, through: :task
  has_one :path, through: :section
  
  validates :user_id, presence: true
  validates :task_id, presence: true
  validates_uniqueness_of :task_id, :scope => :user_id
  validates :status_id, presence: true

  def complete_multiple_choice(answer_id = nil, points = 100)
    raise "Already answered" if self.status_id != Answer::INCOMPLETE
    raise "Out of time" if points > 0 and self.created_at <= 45.seconds.ago
    a = Answer.find(answer_id)
    self.answer_id = a.id
    correct_answer = task.correct_answer
    if a == correct_answer
      self.status_id = Answer::CORRECT
      self.points_awarded = points
    else
      self.status_id = Answer::INCORRECT
      self.points_awarded = 0
    end
    self.save!
    Answer.increment_counter(:answer_count, self.answer_id)
    user.award_points(task, self.points_awarded)
    return { correct_answer: correct_answer.id, supplied_answer: self.answer_id }
  end
  
  def user_submitted_answer
    return nil if submitted_answer.nil
    return submitted_answer.content
  end
  
  def correct?
    return self.status_id == Answer::CORRECT
  end
end
