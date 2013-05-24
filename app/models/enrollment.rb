class Enrollment < ActiveRecord::Base
  CONTRIBUTION_THRESHOLD = 500
  
  attr_readonly :path_id
  attr_protected :total_points, :contribution_unlocked_at, :highest_rank, :longest_streak, :metascore, :metapercentile
  attr_accessible :path_id, :total_points, :contribution_unlocked
  
  belongs_to  :user
  belongs_to  :path
  has_many    :completed_tasks
  has_many    :submitted_answers, through: :completed_tasks
  has_many    :votes, through: :submitted_answers
  
  validates :user_id, presence: true, uniqueness: { scope: :path_id }
  validates :path_id, presence: true
  
  after_create { path.personas.each { |p| user.enroll!(p) } }
  
  def add_earned_points(points)
    points = points.to_i
    self.total_points = self.total_points + points
    check_for_events(points)
    if rank < highest_rank
      self.highest_rank = rank
    end
    save
  end
  def remove_earned_points(points)
    points = points.to_i
    self.total_points = self.total_points - points
    save
  end
  
  def level() Enrollment.points_to_level(self.total_points) end
  def self.level(total_points) Enrollment.points_to_level(total_points.to_i) end
  def self.points_to_level(points)
    POINT_LEVELS.each do |l, p|
      return l - 1 if points < p
    end
  end

  def points_to_next_level() Enrollment.points_to_next_level(self.total_points) end
  def self.points_to_next_level(points)
    POINT_LEVELS.each do |l, p|
      return p - points if points < p
    end
  end
  
  def level_percent() Enrollment.level_percent(self.total_points) end
  def self.level_percent(points)
    previous_points = 0
    POINT_LEVELS.each do |l, p|
      if points < p
        points_in_level = p - previous_points
        points_so_far = points - previous_points
        return (points_so_far.to_f / points_in_level.to_f) * 100
      else
        previous_points = p
      end
    end
  end
  
  def rank() Enrollment.rank(total_points, path_id) end
  def self.rank(points, path_id) Enrollment.where("path_id = ? and total_points > ?", path_id, points).count + 1 end
  def points_to_next_rank
    e = Enrollment.where("path_id = ? and total_points > ?", path_id, total_points).order("total_points ASC").first
    return e ? (e.total_points - total_points) : 0
  end
    
  def contribution_unlocked?() contribution_unlocked_at.nil? ? false : true end
    
  def tasks() completed_tasks.includes(:task).where("status_id = ? and tasks.answer_type = ?", Answer::CORRECT, Task::CHECKIN) end
  def creative_responses() completed_tasks.includes(:task).where("status_id = ? and tasks.answer_type = ?", Answer::CORRECT, Task::CREATIVE) end
  
  def comments_received
    completed_tasks.joins(:submitted_answer)
      .joins("INNER JOIN comments on comments.owner_id = submitted_answers.id and comments.owner_type = 'SubmittedAnswer'")
      .count
  end
  
  def votes_received
    completed_tasks.joins(:submitted_answer)
      .joins("INNER JOIN votes on votes.owner_id = submitted_answers.id and votes.owner_type = 'SubmittedAnswer'")
      .count
  end
  
  PERCENT_CORRECT_MULTIPLIER  = 50
  TASKS_TAKEN_PENALTY = 0.5
  TASKS_TAKEN_MULTIPLIER = 2.5
  
  # MS = (core_tasks_percent_correct - population_average_core_tasks_percent_correct) * PCM
  # MS = MS + 
  # - if user_average_correct_points > population_average_correct_points
  #     user_average_correct_points - population_average_correct_points
  #   - else
  #       0
  # MS = MS + 
  #   - if core_tasks_taken_count < population_average_core_tasks_taken_count
  #       (core_tasks_taken_count - population_average_core_tasks_taken_count) * TTP
  #   - else 
  #       core_tasks_taken_count / population_average_core_tasks_taken_count
  # MS = MS + completed_cr_count
  # MS = MS +
  #   - if total_votes > 0
  #       2
  #   - else
  #       0
  # MS = MS + (core_tasks_taken_count / population_average_core_tasks_taken_count) * TTM
  
  def calculate_metascore
    path_stats = PATH_AVERAGES[path_id]
    cts = completed_tasks.joins(:task).where("answer_type in (?)", [Task::MULTIPLE, Task::EXACT])
    total_cts = cts.count
    return 0 if total_cts == 0
    
    correct_answers = cts.where("status_id = ?", Answer::CORRECT).count.to_f
    correct_percent = correct_answers / total_cts
    ms = (correct_percent - path_stats[:percent_correct]) * PERCENT_CORRECT_MULTIPLIER
    
    average_correct_points = cts.where("status_id = ?", Answer::CORRECT).average(:points_awarded) || 0
    if average_correct_points > path_stats[:correct_points]
      ms += average_correct_points - path_stats[:correct_points]
    end
    if total_cts < path_stats[:tasks_attempted]
      ms += (total_cts - path_stats[:tasks_attempted]) * TASKS_TAKEN_PENALTY
    else
      ms += total_cts / path_stats[:tasks_attempted]
    end
    ms += 2 if votes.count > 0
    
    ms += (total_cts / path_stats[:tasks_attempted]) * TASKS_TAKEN_MULTIPLIER
    self.metascore = (ms * 10) + 1000
    save!
  end
  
  def self.scores(path)
    where(path_id: path.id).where("total_points > ?", 0).collect{ |e| Score.new(e.metascore, e.id) }.sort!
  end
  
  # L/N(100) = P
  # L = number of scores beneath this score (score array index)
  # N = total number of scores
  # P = percentile
  def calculate_metapercentile(all_scores = nil)
    if all_scores.nil?
      all_scores = Enrollment.scores(path)
    end
    count = all_scores.size
    index = all_scores.find_index { |s| s.enrollment == self.id }
    self.metapercentile = (index.to_f/count.to_f*100).ceil
    save!
  end
  
  def test_fire
    t0 = Time.now
    calculate_metascore
    calculate_metapercentile
    t1 = Time.now
    return [self.id, metascore, metapercentile, (t1 - t0)].join(", ")
  end
  
  private
  
  class Score
    attr_accessor :value, :percentile, :enrollment
    def initialize(score, enrollment)
      self.value = score.to_f
      self.enrollment = enrollment
    end
    def <=>(foo)
      self.value <=> foo.value
    end
  end
  
  def check_for_events(points)
    if crossed_threshold?(CONTRIBUTION_THRESHOLD, points) && !contribution_unlocked?
      self.contribution_unlocked_at = Time.now
      UserEvent.log_point_event(user, self, :contribution_unlocked)
    end
  end
  
  def crossed_threshold?(threshold, delta)
    if self.total_points >= threshold
      if (self.total_points - delta) < threshold
        return true
      end
    end
    return false
  end
end
