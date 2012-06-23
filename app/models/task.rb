class Task < ActiveRecord::Base
  attr_protected :section_id
  attr_accessor :randomize
  attr_accessible :question, :answer1, :answer2, :answer3, :answer4, :points, :resource, :correct_answer, :position, :answer_type, :answer_sub_type
  
  belongs_to   :section
  has_one   :path, :through => :section
  has_many  :completed_tasks
  has_many  :answers
  has_many  :comments, :dependent => :destroy
  has_many  :submitted_answers, :dependent => :destroy, :limit => 10
  
  validates :question, 
    :presence     => true,
    :length      => { :within => 1..255 }
  
  validates :answer1,
    :length      => { :maximum => 255 }
    
  validates :answer2,
    :length      => { :maximum => 255 }

  validates :answer3,
    :length      => { :maximum => 255 }

  validates :answer4,
    :length      => { :maximum => 255 }  

  validates :correct_answer, 
    :presence     => true,
    :numericality  => { :less_than => 5 }
  
  validates :points,
    :numericality  => { :less_than => 51 }
    
  validates :resource,
    :length      => { :maximum => 255 }
  
  validates :section_id, :presence => true
  
  validate  :unique_answers
  
  before_create :set_position
  before_create :record_phrases
  after_create :create_answers
  before_validation :set_point_value
  before_save :check_answer_type
  before_save :randomize_answers
  
  def find_or_create_submitted_answer(content)
    sa = submitted_answers.find_by_task_id_and_content(self.id, content)
    return sa unless sa.nil?
    return submitted_answers.create!(:content => content)
  end
  
  def has_stored_resources
    return StoredResource.find_by_owner_name_and_owner_id("task", self.id)
  end
  
  def stored_resources
    return StoredResource.where("owner_name = ? and owner_id = ?", "task", self.id)
  end
  
  def is_correct?(user_answer)
    if self.answer_type == 1
      correct_answer = answers.first
      possible_correct_answers = correct_answer.content.split(",")
      possible_correct_answers.each do |pca|
        return [1, correct_answer] if same_letters?(user_answer, pca)
      end
      return [0, nil]
    else
      chosen_answer = answers.find_by_id(user_answer)
      if chosen_answer.nil?
        raise "RUNTIME EXCEPTION: Answer ##{user_answer.to_s} is not an option for Task ##{self.id}"
      else
        return [chosen_answer.is_correct? ? 1 : 0, chosen_answer]
      end
    end
  end
  
  def describe_answer(answer)
    answers = [nil,answer1,answer2,answer3,answer4]
    return answers[Integer(answer)]
  end
  
  def describe_correct_answer
    answers.where("is_correct = ?", true).first.content
  end
  
  def describe_answers
    answers = [answer1,answer2,answer3,answer4]
    answers = answers.unshift(describe_correct_answer).unshift(nil)
    answers = answers.uniq
    return answers
  end
  
  def question_type
    return answers_to_array.size == 1 ? "text" : "multiple"
  end
  
  def total_answers
    total_answers = answers.sum(:answer_count)
  end
  
  def fib_answer_breakdown
    if self.answer_type == 1
      number_correct = completed_tasks.where("status_id = 1").count
      number_incorrect = completed_tasks.where("status_id = 0").count
      unless number_correct == 0 && number_incorrect == 0
        return ((number_correct.to_f / (number_correct + number_incorrect).to_f) * 100).to_i
      else
        return 0
      end
    else
      raise "RUNTIME EXCEPTION: Using fib_guess_breakdown when not FIB"
    end
  end
  
  private
    def check_answer_type
      unless self.answer_type == 0
        self.answer_sub_type = nil
      end
    end
    
    def set_point_value
      self.points = 10 if self.points.nil? || self.points == 0
    end
    
    def same_letters?(word, str)
      word = word.downcase.strip
      str = str.downcase.strip
      
      return false unless word.size == str.size
      str.split(//).each do |s|
        return false unless word.include?(s)
      end
      return true
    end
  
    def randomize_answers
      answers = answers_to_array
      if answers.size > 1
        answers = answers.shuffle
        logger.debug "RANDOMIZEEEE!"
        logger.debug answers
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
    
    def create_answers
      answers.create!(:content => self.answer1, :is_correct => (self.correct_answer == 1)) unless self.answer1.blank?
      answers.create!(:content => self.answer2, :is_correct => (self.correct_answer == 2)) unless self.answer2.blank?
      answers.create!(:content => self.answer3, :is_correct => (self.correct_answer == 3)) unless self.answer3.blank?
      answers.create!(:content => self.answer4, :is_correct => (self.correct_answer == 4)) unless self.answer4.blank?
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
    
    def unique_answers
      answers = answers_to_array
      unless answers.uniq!.nil?
        errors[:base] << "All answers must be different."
      end
    end
end
