class UserPersona < ActiveRecord::Base
  attr_accessible :persona_id, :updated_at
  
  belongs_to  :user
  belongs_to  :persona
  
  validates :user_id, presence: true, uniqueness: { scope: :persona_id }
  validates :persona_id, presence: true
  
  default_scope { order 'updated_at desc' }
  
  def total_points
    @total_points ||= persona.paths.joins(:enrollments).where("enrollments.user_id = ?", user.id).sum("enrollments.total_points").to_i
    return @total_points
  end
  def level() Enrollment.points_to_level(total_points) end
  def percent_level() Enrollment.level_percent(total_points) end
  def points_to_next_level() Enrollment.points_to_next_level(total_points) end
    
  def enrollments
    user.enrollments
      .joins("JOIN path_personas on path_personas.path_id = enrollments.path_id")
      .where("path_personas.persona_id = ? and enrollments.total_points > 0", persona_id)
  end
end
