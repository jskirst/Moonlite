class Enrollment < ActiveRecord::Base
	attr_accessible :path_id, :total_points
	
	belongs_to :user
	belongs_to :path
	
	validates :user_id, :presence => true, :uniqueness => { :scope => :path_id }
	validates :path_id, :presence => true, :uniqueness => { :scope => :user_id }
	
	def add_earned_points(points)
		if self.total_points.nil?
			self.total_points = 0
		end
		self.total_points = self.total_points + points
		self.save
	end
	
	def total_earned_points()
		if self.total_points.nil?
			return 0
		else
			return self.total_points
		end
	end
end
