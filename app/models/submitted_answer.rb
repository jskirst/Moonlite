class SubmittedAnswer < ActiveRecord::Base
  attr_protected :task_id, :total_votes
  attr_accessible :content
  
  belongs_to :task
  has_many :completed_tasks
  has_many :users, :through => :completed_task
 
  validates :content, 
    :presence     => true,
    :length      => { :within => 1..2500 }
    
  def add_vote
    self.total_votes += 1
    save
  end
    
end
