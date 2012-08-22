class Enrollment < ActiveRecord::Base
  attr_readonly :path_id
  attr_accessible :path_id, :total_points, :is_complete, :is_score_sent, :percentage_correct, :is_passed
  
  belongs_to :user
  belongs_to :path
  
  validates :user_id, presence: true, uniqueness: { scope: :path_id }
  validates :path_id, presence: true
  validate do
    errors[:base] << "Msg"  "Error 95" unless user.company_id == path.company_id 
  end
  
  def retake!
    raise "Retakes for this path are not allowed." unless path.enable_path_retakes
    self.is_complete = false
    self.is_score_sent = false
    self.is_passed = false
    self.percentage_correct = nil
    self.total_points = 0
    raise "Retake failed: "+ self.errors.to_yaml unless self.save
  end
  
  def add_earned_points(points)
    points = points.to_i
    self.total_points = self.total_points + points
    self.save!
  end
  
  def send_result_email
    email_details = { enrollment: self, path: path, user: user }
    Mailer.path_result(email_details).deliver
  end
end
