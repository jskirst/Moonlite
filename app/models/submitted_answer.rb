class SubmittedAnswer < ActiveRecord::Base
  attr_protected :completed_task_id
  attr_accessible :content
  
  belongs_to :completed_task
  has_one :task, :through => :completed_task
  has_one :user, :through => :completed_task
  
  validates :completed_task_id, :presence => true
 
  validates :content, 
    :presence     => true,
    :length      => { :within => 1..2500 }
    
end
