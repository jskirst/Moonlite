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
	
	#should return the lowest pointsing task belonging 
	#to the path that is not found among the completed tasks 
	#for the current user
	# TEST
	def next_task(user, previous_question = nil)
		tasks.each do |t|
			if !user.completed?(t)
				if t != previous_question
					return t
				end
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
	
	def get_user_rank(user)
		completed_task_count = 0
		tasks.each do |t|
			if user.completed?(t)
				completed_task_count += 1
			end
		end
		return completed_task_count/5
	end
	
	def tasks_until_next_rank(user)
		completed_task_count = 0
		tasks.each do |t|
			if user.completed?(t)
				completed_task_count += 1
			end
		end
		return 5-(completed_task_count.remainder(5))
	end
end