class UserPersona < ActiveRecord::Base
  attr_accessible :persona_id, :updated_at
  
  belongs_to :user
  belongs_to :persona
  
  validates :user_id, presence: true, uniqueness: { scope: :persona_id }
  validates :persona_id, presence: true
  
  default_scope order: 'updated_at desc'
  
  def total_points
    return persona.paths.joins(:enrollments).where("enrollments.user_id = ?", user.id).sum("enrollments.total_points").to_i
  end
  
  def level
    return total_points / 300
  end
  
  def percent_level
    return (total_points % 300) / 3
  end
  
  def points_in_level
    return total_points < 300 ? total_points : total_points % 300
  end
  
  def points_to_next_level
    (points_in_level - 300) * -1
  end
end
