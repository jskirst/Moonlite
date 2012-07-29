class CompletedTask < ActiveRecord::Base
  attr_readonly :task_id, :submitted_answer_id, :answer_id, :status_id
  attr_protected :task_id, :points_awarded
  attr_accessible :updated_at, :answer
  
  belongs_to :user
  belongs_to :task
  belongs_to :submitted_answer
  belongs_to :chosen_answer, class_name: "Answer"
  has_one :section, through: :task
  has_one :path, through: :section
  has_one :category, through: :path
  
  validates :user_id, presence: true
  validates :task_id, presence: true
  validates :status_id, presence: true

  validate(on: :create) do 
    errors.add_to_base "Must be enrolled" unless user.enrolled?(task.path) 
  end
  
  def user_submitted_answer
    return nil if submitted_answer.nil
    return submitted_answer.content
  end
end
