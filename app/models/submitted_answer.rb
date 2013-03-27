require 'open-uri'
class SubmittedAnswer < ActiveRecord::Base
  POINTS_PER_VOTE = 50

  attr_protected :task_id, :total_votes, :locked_at, :reviewed_at
  attr_accessible :url, 
    :content, 
    :caption,
    :description,
    :title,
    :image_url,
    :site_name,
    :preview,
    :preview_errors
  
  belongs_to :task
  has_one :completed_task, dependent: :destroy
  has_one :path, through: :completed_task
  has_one :user, through: :completed_task
  has_many :comments, as: :owner
  has_many :votes, as: :owner, dependent: :destroy
  has_many :stored_resources, as: :owner
 
  validates :content, length: { maximum: 2500 }
  
  before_save do
    if content.include?("#ruby")
      url = URI.parse("http://www.evaluatron.com/?quarry=#{CGI.escape(content)}")
      result = JSON.parse(open(url).read)
      self.preview = result["output"]
      self.preview_errors = result["errors"]
    end
  end
  
  def reviewed?() not reviewed_at.nil? end
  
  # def preview
  #   return stored_resources.first.obj.url unless stored_resources.empty?
  #   return url unless url.blank?
  #   return STONEY_SMALL_URL
  # end
    
  def add_vote(voting_user)
    if vote = voting_user.votes.create!(owner_id: self.id)
      self.total_votes += 1
      completed_task.update_attribute(:points_awarded, (completed_task.points_awarded += POINTS_PER_VOTE))
      user.award_points(vote, POINTS_PER_VOTE)
      return vote if save
    end
    return false
  end
  
  def subtract_vote(voting_user, vote)
    vote.destroy
    if self.total_votes > 0
      self.total_votes -= 1
      completed_task.update_attribute(:points_awarded, (completed_task.points_awarded -= POINTS_PER_VOTE))
      completed_task.user.retract_points(vote, POINTS_PER_VOTE)
      return true if save
    else
      raise "Fatal: Have negative votes somehow"
    end
    return false
  end
end
