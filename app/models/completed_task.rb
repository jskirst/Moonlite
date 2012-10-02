class CompletedTask < ActiveRecord::Base
  attr_readonly :task, :submitted_answer, :answer
  attr_protected :points_awarded, :status_id
  attr_accessible :updated_at, :task, :answer, :submitted_answer
  
  belongs_to :user
  belongs_to :task
  belongs_to :submitted_answer, dependent: :destroy
  belongs_to :chosen_answer, class_name: "Answer"
  has_one :section, through: :task
  has_one :path, through: :section
  has_one :category, through: :path
  
  validates :user_id, presence: true
  validates :task_id, presence: true
  validates :status_id, presence: true

  validate(on: :create) do
    raise "Already answered." if user.completed_tasks.find_by_task_id(task.id)
    raise "Must be enrolled" unless user.enrolled?(task.path) 
  end
  
  after_create do
    Answer.increment_counter(:answer_count, answer_id) unless answer_id.nil?
  end
  
  def user_submitted_answer
    return nil if submitted_answer.nil
    return submitted_answer.content
  end
end
