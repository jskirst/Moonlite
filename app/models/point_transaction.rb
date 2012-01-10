class PointTransaction < ActiveRecord::Base
	attr_accessible :user_id, 
		:task_id, 
		:reward_id, 
		:points, 
		:status
	
	belongs_to :user
	belongs_to :task
	belongs_to :reward
	
	validates :user_id, 
		:presence => true
	validates :points,
		:presence 	=> true
	validates :status,
		:presence 	=> true
end
