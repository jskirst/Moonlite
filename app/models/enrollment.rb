class Enrollment < ActiveRecord::Base
  CONTRIBUTION_THRESHOLD = 100
  
  attr_readonly :path_id
  attr_protected :total_points, :contribution_unlocked_at, :highest_rank, :longest_streak, :metascore, :metapercentile
  attr_accessible :path_id, :total_points, :contribution_unlocked, :private_at
  
  belongs_to  :user
  belongs_to  :path
  belongs_to  :evaluation
  has_many    :completed_tasks
  has_many    :submitted_answers, through: :completed_tasks
  has_many    :votes, through: :submitted_answers
  
  validates :user_id, presence: true, uniqueness: { scope: :path_id }
  validates :path_id, presence: true
  
  after_initialize { self.metascore ||= 0 }
  
  after_create do 
    path.personas.each do |p| 
      begin
        user.enroll!(p)
      rescue
        raise user.to_yaml + p.to_yaml
      end
    end
  end

  def next_task(user:, path:, section: nil, answer_types:, answer_sub_types: nil, difficulty: 0, count: 1)
    ct_query = "SELECT * FROM completed_tasks ct WHERE ct.user_id = ? and ct.task_id = tasks.id"
    ct_query += " and ct.status_id is not NULL and ct.status_id >= 0"
    
    tasks = Task.where(path_id: path)
      .where(locked_at: nil)
      .where.not(reviewed_at: nil)
      .where("tasks.answer_type in (?)", answer_types)
      .where("NOT EXISTS (#{ct_query})", user.id)
      .order("@(#{difficulty.to_f} - tasks.difficulty) DESC")
    
    tasks = tasks.where(section_id: section) if section
    tasks = tasks.where("tasks.answer_sub_type in (?)", answer_sub_types) if answer_sub_types
    
    return count == 1 ? tasks.first : tasks.first(count)
  end
  
  def add_earned_points(points)
    points = points.to_i
    self.total_points = self.total_points + points
    check_for_events(points)
    calculate_highest_rank
    save!
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

  def describe_skill_level() Enrollment.describe_skill_level(self.metascore) end
  def self.describe_skill_level(metascore)
    metascore = metascore.to_i
    if metascore <= 392
      return "Unqualified"
    elsif metascore > 392 and metascore <= 484
      return "Novice"
    elsif metascore > 484 and metascore <= 576
      return "Familiar"
    elsif metascore > 576 and metascore <= 668
      return "Competent"
    elsif metascore > 668 and metascore <= 760
      return "Advanced"
    elsif metascore > 760
      return "Expert"
    end
  end
  
  def describe_consumer_skill_level() Enrollment.describe_consumer_skill_level(self.metascore) end
  def self.describe_consumer_skill_level(metascore)
    metascore = metascore.to_i
    if metascore <= 392
      return "Beginner"
    elsif metascore > 392 and metascore <= 484
      return "Novice"
    elsif metascore > 484 and metascore <= 576
      return "Familiar"
    elsif metascore > 576 and metascore <= 668
      return "Learned"
    elsif metascore > 668 and metascore <= 760
      return "Advanced"
    elsif metascore > 760
      return "Expert"
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
  def self.rank(points, path_id) 
    Enrollment.joins(:user)
      .where("users.private_at is ? and users.locked_at is ?", nil, nil)
      .where("path_id = ? and total_points > ?", path_id, points).count + 1 
  end
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
  
  def calculate_metascore
    cts = completed_tasks.joins(:task)
      .where("answer_type in (?)", [Task::MULTIPLE, Task::EXACT])
      .select("tasks.difficulty, completed_tasks.*")
    if cts.empty? 
      self.metascore = 0
      save! and return
    end
    
    ct_constant = 0.00835
    ct_multiplier = [1.0 + ct_constant * cts.count, 1.3].min 
    incorrect_constant = 310.0
    bump_constant = 365.0
    summ_correct = 0.0
    summ_incorrect = 0.0
    
    cts.each do |ct|
      difficulty = ct.difficulty < 1.0 ? 1.0 : ct.difficulty.to_f
      if ct.correct?
        pos_delta = difficulty * ct.points_awarded * ct_multiplier
        summ_correct += pos_delta
      elsif ct.incorrect? or ct.incomplete?
        neg_delta = incorrect_constant.to_f / difficulty
        summ_incorrect += neg_delta
      else
        raise ct.to_yaml
      end
    end
    
    if summ_correct == 0
      self.metascore = 300
    else
      ms_correct = summ_correct/ cts.count
      ms_incorrect = summ_incorrect / cts.count
      self.metascore = (ms_correct - ms_incorrect) + bump_constant
      # Tier MS to zero
      x = self.metascore - 305.0
      # Get percentage of old range
      y = (x / 160.0)
      # Multiply by new range
      z = (y * 368.0)
      # Add min of new range
      self.metascore = z + 392.0
    end
    
    if self.metascore > 850
      self.metascore = 850
    elsif self.metascore < 300
      self.metascore = 300
    end
    
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
  
  def calculate_highest_rank
    current_highest_rank = highest_rank == 0 ? 10000000 : highest_rank
    if rank > 0 and rank < current_highest_rank
      self.highest_rank = rank
      return self.highest_rank
    else
      return false
    end
  end
  
  def public?
    self.private_at.nil?
  end
  
  def to_json
    {
      total_points: self.total_points,
      metascore: self.metascore,
      id: self.id,
      private_at: self.private_at
    }
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
