class SubmittedAnswer < ActiveRecord::Base
  POINTS_PER_VOTE = 50

  attr_protected :task_id, :total_votes, :locked_at, :reviewed_at
  attr_accessible :content
  
  belongs_to :task
  has_one :completed_task, dependent: :destroy
  has_one :path, through: :completed_task
  has_one :user, through: :completed_task
  has_many :comments, as: :owner
  has_many :votes
  has_many :stored_resources, as: :owner
 
  validates :content, length: { maximum: 2500 }
    
  def add_vote(voting_user)
    if vote = voting_user.votes.create!(owner_id: self.id)
      self.total_votes += 1
      completed_task.update_attribute(:points_awarded, (completed_task.points_awarded += POINTS_PER_VOTE))
      user.award_points(completed_task, POINTS_PER_VOTE)
      return vote if save
    end
    return false
  end
  
  def subtract_vote(user)
    if self.total_votes > 0
      self.total_votes -= 1
      completed_task.update_attribute(:points_awarded, (completed_task.points_awarded -= POINTS_PER_VOTE))
      user.retract_points(completed_task, POINTS_PER_VOTE)
      return true if save
    end
    return false
  end
end
