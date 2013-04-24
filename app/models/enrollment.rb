class Enrollment < ActiveRecord::Base
  CONTRIBUTION_THRESHOLD = 500
  
  attr_readonly :path_id
  attr_protected :total_points, :contribution_unlocked_at, :highest_rank, :longest_streak
  attr_accessible :path_id, :total_points, :contribution_unlocked
  
  belongs_to  :user
  belongs_to  :path
  has_many    :completed_tasks
  
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
  
  private
  
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
