class Answer < ActiveRecord::Base
  attr_protected :task_id
  attr_accessible :content, :is_correct, :answer_count
  
  belongs_to   :task
  has_many  :completed_tasks
  
  validates :content, 
    :presence     => true,
    :length      => { :within => 1..255 }
end
