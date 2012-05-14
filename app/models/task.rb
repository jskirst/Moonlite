class Task < ActiveRecord::Base
	attr_protected :section_id
	attr_accessible :question, :answer1, :answer2, :answer3, :answer4, :points, :resource, :correct_answer, :position
	before_create :set_position
  before_create :randomize_answers
  before_create :record_phrases
  
	belongs_to 	:section
	has_one 	:path, :through => :section
  has_one   :info_resource
	has_many	:completed_tasks
  has_many  :comments, :dependent => :destroy
	
	validates :question, 
		:presence 		=> true,
		:length			=> { :within => 1..255 }
	
	validates :answer1,
		:length			=> { :maximum => 255 }
		
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
		:numericality	=> { :less_than => 51 }
		
	validates :resource,
		:length			=> { :maximum => 255 }
	
	validates :section_id, :presence => true
	
	#default_scope :order => 'tasks.position ASC'
	
	def is_correct?(user_answer, type)
		if type == "text"
			answers = describe_correct_answer.downcase.split(",")
			answers.each do |answer|
				return true if same_letters?(user_answer, answer)
			end
			return false
		else
			return Integer(user_answer) == Integer(self.correct_answer)
		end
	end
	
	def describe_answer(answer)
		answers = [nil,answer1,answer2,answer3,answer4]
		return answers[Integer(answer)]
	end
	
	def describe_correct_answer
		answers = [nil,answer1,answer2,answer3,answer4]
		return answers[correct_answer]
	end
	
	def question_type
		return answers_to_array.size == 1 ? "text" : "multiple"
	end
  
  private
		def same_letters?(word, str)
			word = word.downcase
			str = str.downcase
			
			return false unless word.size == str.size
			str.split(//).each do |s|
				return false unless word.include?(s)
			end
			return true
		end
	
    def randomize_answers
      answers = answers_to_array
      if self.correct_answer == 1 && answers.size > 1
        answers = answers.shuffle
        self.correct_answer = answers.index(self.answer1.chomp) + 1
        self.points = 10
        self.answer1 = answers[0]
        self.answer2 = answers[1]
        self.answer3 = answers[2]
        self.answer4 = answers[3]
      end
    end
    
    def record_phrases
      PhrasePairing.create_phrase_pairings(answers_to_array)
    end
    
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
    
    def answers_to_array
      answers = []
      answers << self.answer1.chomp unless self.answer1.blank?
      answers << self.answer2.chomp unless self.answer2.blank?
      answers << self.answer3.chomp unless self.answer3.blank?
      answers << self.answer4.chomp unless self.answer4.blank?
			return answers
    end
    
    def answers_to_hash_array
      answer_list = []
      answers = @task.answers_to_array
      
      answer_name = "answer"+self.correct_answer.to_s
      @answer_list << {:answer_name => answer_name, :answer => answers[self.correct_answer]}
      answers.each_index do |ai|
        unless ai == self.correct_answer
          answer_name = "answer"+ai.to_s
          answer_list << {:answer_name => answer_name, :answer => answers[ai]}
        end
      end
      return answer_list
    end
end
