class Task < ActiveRecord::Base
	attr_accessible :question, :answer1, :answer2, :answer3, :answer4, :points, :resource, :correct_answer, :position
	before_create :set_position
  
	belongs_to 	:section
	has_one 	:path, :through => :section
	has_many	:completed_tasks
  has_many  :comments, :dependent => :destroy
	
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
	
	validates :section_id, :presence => true
	
	default_scope :order => 'tasks.position ASC'
	
	def describe_correct_answer
		answers = [nil,answer1,answer2,answer3,answer4]
		return answers[correct_answer]
	end
  
  private
    def set_position
			self.position = get_next_position_for_section
		end
    
    def get_next_position_for_section
      unless section.tasks.empty?
        return section.tasks.last.position + 1
      else
        return 1
      end
    end
end
