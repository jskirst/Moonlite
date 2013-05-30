class Answer < ActiveRecord::Base
  INCOMPLETE = -1
  INCORRECT = 0
  CORRECT = 1
  
  attr_protected :task_id
  attr_accessible :content, :is_correct, :answer_count
  
  belongs_to :task
  has_many :completed_tasks
  
  validates :content, length: { :within => 1..255 }
  
  after_save do
    Rails.cache.delete([self.class.name, id])
    Rails.cache.delete([self.class.name, "task_answers", task_id])
  end
  
  def match?(supplied_answer)
    supplied_answer.downcase.gsub(/\s/,'') == content.downcase.gsub(/\s/,'')
  end
    
  def answer_percent
    total_answers_for_task = task.total_answers
    return 0 if total_answers_for_task == 0
    return ((self.answer_count.to_f / total_answers_for_task.to_f).to_f * 100).to_i
  end
  
  # Cached methods
  
  def self.cached_find(id)
    Rails.cache.fetch([self.to_s, id]){ find(id) }
  end
  
  def self.cached_find_by_task_id(task_id)
    Rails.cache.fetch([self.to_s, "task_answers", task_id]){ where("answers.task_id = ?", task_id).to_a }
  end
end
