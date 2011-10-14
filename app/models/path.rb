class Path < ActiveRecord::Base
	attr_accessible :name, :description
	
	belongs_to :user
	has_many :tasks, :dependent => :destroy
	has_many :enrollments, :dependent => :destroy
	
	validates :name, 
		:presence => true,
		:length		=> { :within => 2..80 }
	
	validates :description, 
		:presence => true
	
	validates :user_id, :presence => true
	
	default_scope :order => 'paths.created_at DESC'
	
	#should return the lowest ranking task belonging 
	#to the path that is not found among the completed tasks 
	#for the current user
	# TEST
	def next_task(user)
		tasks.each do |t|
			if !user.completed?(t)
				return t
			end
		end
		return nil
	end
	
	def remaining_tasks(user)
		remaining_task_count = 0
		tasks.each do |t|
			if !user.completed?(t)
				remaining_task_count += 1
			end
		end
		return remaining_task_count
	end
end