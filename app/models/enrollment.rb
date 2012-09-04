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
    unless self.save
      raise points.to_yaml
    end
  end
  
  def send_result_email
    email_details = { enrollment: self, path: path, user: user }
    Mailer.path_result(email_details).deliver
  end
  
  def level
    level = total_points / 40
    return level > 0 ? level : 1
  end
  
  def skill_ranking
    points = self.total_points.to_i
    possible = path.tasks.count * 10
    case
      when points > 1.3 * possible
        return "Master"
      when points > 1.1 * possible
        return "Elite"
      when points > 0.9 * possible
        return "Expert"
      when points > 0.7 * possible
        return "Highly Knowledgeable"
      when points > 0.5 * possible
        return "Intermediate"
      else
        return "Beginner"
      end
  end
end
