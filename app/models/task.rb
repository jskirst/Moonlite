class Task < ActiveRecord::Base
	attr_accessible :question, :answer1, :answer2, :answer3, :answer4, :points, :resource, :correct_answer
	
	belongs_to 	:section
	has_one 	:path, :through => :section
	has_many	:completed_tasks
	
	validates :question, 
		:presence 		=> true,
		:length			=> { :within => 1..255 }
	
	validates :answer1, 
		:presence 		=> true,
		:length			=> { :within => 1..255 }
		
	validates :answer2,
		:presence 		=> true,
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
	
	validates :section_id, :presence => true
	
	default_scope :order => 'tasks.points ASC'
	
	def describe_correct_answer
		answers = [nil,answer1,answer2,answer3,answer4]
		return answers[correct_answer]
	end
end
