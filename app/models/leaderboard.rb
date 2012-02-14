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
end
