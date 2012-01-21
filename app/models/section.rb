class Section < ActiveRecord::Base
	attr_accessible :name, :instructions, :position
	
	before_validation :set_position
	
	belongs_to :path
	has_many :tasks, :dependent => :destroy
	has_many :completed_tasks, :through => :tasks
	
	validates :name, 
		:presence 		=> true,
		:length			=> { :within => 1..255 }
	
	validates :instructions, 
		:presence 		=> true,
		:length			=> { :within => 1..255 }
		
	validates :position,
		:presence		=> true
	
	validates :path_id, 
		:presence 		=> true
		
	default_scope :order => 'position ASC'
		
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
		
	private
		def set_position
			self.position = 0
		end
end
