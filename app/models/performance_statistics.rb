class PerformanceStatistics
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :total, :number_correct, :number_incorrect, :percent_correct, 
    :avg_time_to_answer, :strengths, :weaknesses, :completed_tasks
  
  def initialize(completed_tasks)
    self.completed_tasks = completed_tasks
    self.total = self.completed_tasks.size
    if self.total == 0
      self.number_correct = 0
      self.number_incorrect = 0
      self.percent_correct = 0
    else
      self.number_correct = self.completed_tasks.select{ |ct| ct.status_id == Answer::CORRECT }.size
      self.number_incorrect = self.total - self.number_correct
      self.percent_correct = ((self.number_correct.to_f / self.total) * 100).to_i
    end
    calculate_saw
    calculate_avg_time_to_answer
  end
  
  def calculate_saw
    saw = {}
    self.completed_tasks.each do |ct|
      n = ct.name
      saw[n] = [0, 0] if saw[n].nil?
      saw[n] = ct.correct? ? [saw[n][0] + 1, saw[n][1]] : [saw[n][0], saw[n][1] + 1]
    end
    saw = saw.select{ |name, stats| (stats[0] + stats[1]) >= 2 }
    self.strengths = saw.select{ |topic_name, stats| (stats[0].to_f / (stats[0]+stats[1])) > 0.75 }
    self.weaknesses = saw.select{ |topic_name, stats| (stats[1].to_f / (stats[0]+stats[1])) > 0.5 }
  end
  
  def calculate_avg_time_to_answer
    self.avg_time_to_answer = self.completed_tasks.inject(0){ |sum, ct| sum += ct.updated_at - ct.created_at }
  end
  
  def persisted?
    false
  end
end