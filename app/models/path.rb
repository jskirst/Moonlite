class Path < ActiveRecord::Base
	attr_accessible :name, :description, :company_id
	
	belongs_to :user
	belongs_to :company
	has_many :tasks, :dependent => :destroy
	has_many :enrollments, :dependent => :destroy
	has_many :info_resources, :dependent => :destroy
	
	validates :name, 
		:presence => true,
		:length		=> { :within => 2..80 }
	
	validates :description, 
		:presence => true,
		:length		=> { :within => 2..500 }
	
	validates :user_id, :presence => true
	
	validate :company_id, :if => :user_belongs_to_company, :allow_nil => true
	
	default_scope :order => 'paths.created_at DESC'
	
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
	
	def user_belongs_to_company
		if company != nil
			if user.company != company
				errors[:base] << "User does not belong to this company."
			end
		end
	end
end