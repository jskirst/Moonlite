class SubmittedAnswer < ActiveRecord::Base
  POINTS_PER_VOTE = 5
  
  attr_protected :task_id, :total_votes
  attr_accessible :content
  
  belongs_to :task
  has_many :completed_tasks, dependent: :destroy
  has_many :users, through: :completed_task
  has_many :comments, as: :owner
  has_many :stored_resources, as: :owner
 
  validates :content, length: { maximum: 2500 }
    
  def add_vote(user)
    if vote = user.votes.create!(submitted_answer_id: self.id)
      self.total_votes += 1
      completed_tasks.each do |ct| 
        ct.update_attribute(:points_awarded, (ct.points_awarded += POINTS_PER_VOTE))
        user.award_points(ct.task, POINTS_PER_VOTE)
      end
      return vote if save
    end
    return false
  end
  
  def subtract_vote(user)
    if self.total_votes > 0
      self.total_votes -= 1
      completed_tasks.each do |ct| 
        ct.update_attribute(:points_awarded, (ct.points_awarded -= POINTS_PER_VOTE))
        user.retract_points(ct.task, POINTS_PER_VOTE)
      end
      return true if save
    end
    return false
  end
    
end
