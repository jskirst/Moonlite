class Enrollment < ActiveRecord::Base
  attr_readonly :path_id
  attr_accessible :path_id, :total_points, :is_complete
  
  belongs_to :user
  belongs_to :path
  
  validates :user_id, presence: true, uniqueness: { scope: :path_id }
  validates :path_id, presence: true
  validate do
    errors[:base] << "Msg"  "Error 95" unless user.company_id == path.company_id 
  end
  
  def add_earned_points(points)
    self.total_points = self.total_points + points
    self.save!
  end
end
