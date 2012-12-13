class Enrollment < ActiveRecord::Base
  attr_readonly :path_id
  attr_accessible :path_id, :total_points
  
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
    unless self.save
      raise points.to_yaml
    end
  end
  
  def send_result_email
    email_details = { enrollment: self, path: path, user: user }
    Mailer.path_result(email_details).deliver
  end
  
  def self.points_to_level(points)
    level = points / 300
    return level > 0 ? level : 1
  end
  
  def level
    Enrollment.points_to_level(self.total_points)
  end
end
