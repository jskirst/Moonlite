class Task < ActiveRecord::Base
  attr_readonly :section_id
  attr_accessor :randomize
  attr_accessible :question,
    :points,
    :position, 
    :answer_type, 
    :answer_sub_type,
    :disable_time_limit,
    :time_limit
  
  belongs_to :section
  has_one :path, through: :section
  has_many :completed_tasks
  has_many :answers
  has_many :comments, dependent: :destroy
  has_many :submitted_answers, dependent: :destroy, limit: 10
  has_many :stored_resources, as: :owner
  has_many :comments, as: :owner
  
  validates :question, length: { :within => 1..255 }
  validates :points, presence: true, numericality: { :less_than => 51 }
  validates :section_id, :presence => true
  validate do
    answers_content = answers_to_array
    errors[:base] << "All answers must be different." unless answers_content.uniq!.nil?
  end
  
  before_validation { self.points = 10 if (self.points.nil? || self.points == 0) }
  before_create { self.position = get_next_position_for_section }
  before_save { self.answer_sub_type = nil unless self.answer_type == 0 }
  after_create :create_answers
  after_create :record_phrases
  
  def find_or_create_submitted_answer(content)
    sa = submitted_answers.find_by_task_id_and_content(self.id, content)
    return sa unless sa.nil?
    return submitted_answers.create!(:content => content)
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
  
  def get_correct_answer
    answers.where("is_correct = ?", true).first.content
  end
  
  def describe_answers
    all_answers = answers_to_array
    correct_answer = get_correct_answer
    all_answers = all_answers.unshift(correct_answer).unshift(nil)
    all_answers = all_answers.uniq
    return all_answers
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
    def same_letters?(word, str)
      word = word.downcase.strip
      str = str.downcase.strip
      
      return false unless word.size == str.size
      str.split(//).each do |s|
        return false unless word.include?(s)
      end
      return true
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
    
    def get_next_position_for_section
      return section.tasks.last.position + 1 unless section.tasks.empty?
      return 1
    end
    
    def answers_to_array
      return answers.to_a.collect { |a| a.content }
    end
end
