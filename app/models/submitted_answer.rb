class SubmittedAnswer < ActiveRecord::Base
  attr_protected :task_id, :total_votes
  attr_accessible :content
  
  belongs_to :task
  has_many :completed_tasks, :dependent => :destroy
  has_many :users, :through => :completed_task
 
  validates :content, 
    :presence     => true,
    :length      => { :within => 1..2500 }
    
  def add_vote(user)
    if vote = user.votes.create!(:submitted_answer_id => self.id)
      self.total_votes += 1
      if save
        return vote
      end
   end
   return false
  end
  
  def subtract_vote(user)
    if self.total_votes > 0
      self.total_votes -= 1
      if save
        return true
      end
    end
    return false
  end
    
end
