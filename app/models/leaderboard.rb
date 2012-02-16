class Leaderboard < ActiveRecord::Base
  attr_accessible :user_id, :completed_tasks, :score, :created_at
	
	belongs_to :user
  
  validates :user_id, 
    :presence => true
	validates :completed_tasks, 
    :presence => true,
    :numericality	=> true
	validates :score, 
    :presence => true,
    :numericality	=> true
  
  default_scope :order => "leaderboards.created_at DESC"
  
  def self.get_rank(user)
    previous_board = Leaderboard.first
    latest_date = previous_board.nil? ? Time.now : previous_board.created_at
    return Leaderboard.where(["created_at = ? and score > ?", latest_date, user.earned_points]).count(:order => "score DESC") + 1
  end
end
