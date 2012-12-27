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
  
  def user_submitted_answer
    return nil if submitted_answer.nil
    return submitted_answer.content
  end
  
  def correct?
    return self.status_id == Answer::CORRECT
  end
end
