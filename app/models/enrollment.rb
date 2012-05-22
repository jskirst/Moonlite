class Enrollment < ActiveRecord::Base
  attr_accessible :path_id, :total_points
  
  belongs_to :user
  belongs_to :path
  
  validates :user_id, :presence => true, :uniqueness => { :scope => :path_id }
  validates :path_id, :presence => true, :uniqueness => { :scope => :user_id }
  validate  :company_owns_path
  
  def add_earned_points(points)
    self.total_points = self.total_points + points
    self.save!
  end
  
  def total_earned_points()
    return self.total_points
  end
  
  private
    def company_owns_path
      unless path.nil? || user.nil? || user.company == path.company
        errors[:base] << "User's company must own this path for the user to enroll."
      end
    end
end
