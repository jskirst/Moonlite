class Task < ActiveRecord::Base
	attr_accessible :question, :answer1, :answer2, :answer3, :answer4, :points, :resource, :correct_answer
	
	belongs_to :path
	
	validates :question, 
		:presence 		=> true,
		:length			=> { :within => 1..255 }
	
	validates :answer1, 
		:presence 		=> true,
		:length			=> { :within => 1..255 }
		
	validates :answer2,
		:length			=> { :maximum => 255 }

	validates :answer3,
		:length			=> { :maximum => 255 }

	validates :answer4,
		:length			=> { :maximum => 255 }	

	validates :correct_answer, 
		:presence 		=> true,
		:numericality	=> { :less_than => 5 }
	
	validates :points, 
		:presence 		=> true,
		:numericality	=> { :less_than => 51 }
		
	validates :resource,
		:length			=> { :maximum => 255 }
	
	validates :path_id, :presence => true
	
	default_scope :order => 'tasks.points ASC'
	
	def describe_correct_answer  
		if correct_answer == 1 
			return answer1
		elsif correct_answer == 2 
			return answer2
		elsif correct_answer == 3 
			return answer3
		elsif correct_answer == 4 
			return answer4 
		end 
	end
end
