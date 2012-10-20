class Answer < ActiveRecord::Base
  INCORRECT = 0
  CORRECT = 1
  
  attr_protected :task_id
  attr_accessible :content, :is_correct, :answer_count
  
  belongs_to :task
  has_many :completed_tasks
  
  validates :content, length: { :within => 1..255 }
    
  def answer_percent
    total_answers_for_task = task.total_answers
    return 0 if total_answers_for_task == 0
    return ((self.answer_count.to_f / total_answers_for_task.to_f).to_f * 100).to_i
  end
end
