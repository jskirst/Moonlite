class Enrollment < ActiveRecord::Base
  CONTRIBUTION_THRESHOLD = 1000
  
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
  
  def add_earned_points(points, callback)
    points = points.to_i
    self.total_points = self.total_points + points
    if self.total_points >= CONTRIBUTION_THRESHOLD
      self.contribution_unlocked = true
    end
    if self.save
      callback
    end
  end
  
  def self.points_to_level(points)
    return 1 if points < 2
    points = points.to_f
    level = (points.to_f**0.55) / Math.log(points)
    level = level - (level % 1)
    level = level - 3
    return level <= 0 ? 1 : level.to_i
  end
  
  def level
    Enrollment.points_to_level(self.total_points)
  end
  
  def points_in_level
    points_remaining = self.total_points
    until points_remaining < 300
      points_remaining -= 300
    end
    return points_remaining
  end
  
  def points_to_next_level
    (points_in_level - 300) * -1
  end
  
  def level_percent
    return points_in_level / 3
  end
end
