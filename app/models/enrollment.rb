class Enrollment < ActiveRecord::Base
  attr_readonly :path_id
  attr_accessible :total_points, :is_complete
  
  belongs_to :user
  belongs_to :path
  
  validates :user_id, presence: true, uniqueness: { scope: :path_id }
  validates :path_id, presence: true
  validate do errors.add_to_base "Error 95" unless user.company == path.company end
  
  def add_earned_points(points)
    self.total_points = self.total_points + points
    self.save!
  end
end
