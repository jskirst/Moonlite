class UserAchievement < ActiveRecord::Base
	attr_accessible :achievement_id, :updated_at
	
	belongs_to :user
	belongs_to :achievement
	
	validates :user_id, :presence => true
	validates :achievement_id, :presence => true
	
	default_scope :order => 'updated_at desc'
end
