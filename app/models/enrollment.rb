class Enrollment < ActiveRecord::Base
  CONTRIBUTION_THRESHOLD = 300
  
  attr_readonly :path_id
  attr_accessible :path_id, :total_points, :contribution_unlocked
  
  belongs_to :user
  belongs_to :path
  
  validates :user_id, presence: true, uniqueness: { scope: :path_id }
  validates :path_id, presence: true
  validate do
    errors[:base] << "Msg"  "Error 95" unless self.user.company_id == self.path.company_id 
  end
  
  after_create do
    path.personas.each do |persona|
      user.enroll!(persona)
    end
  end
  
  def add_earned_points(points)
    points = points.to_i
    self.total_points = self.total_points + points
    check_for_events(points)
    save
  end
  
  def self.points_to_level(points)
    POINT_LEVELS.each do |l, p|
      if points < p
        return l - 1
      end
    end
  end
  
  def level
    Enrollment.points_to_level(self.total_points)
  end

  def self.points_to_next_level(points)
    POINT_LEVELS.each do |l, p|
      if points < p
        return p - points
      end
    end
  end
  
  def points_to_next_level
    Enrollment.points_to_next_level(self.total_points)
  end
  
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
  
  def level_percent
    Enrollment.level_percent(self.total_points)
  end
  
  private
  
  def check_for_events(points)
    if crossed_threshold?(CONTRIBUTION_THRESHOLD, points)
      self.contribution_unlocked = true
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
