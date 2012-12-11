class UserPersona < ActiveRecord::Base
  attr_accessible :persona_id, :updated_at
  
  belongs_to :user
  belongs_to :persona
  
  validates :user_id, presence: true, uniqueness: { scope: :persona_id }
  validates :persona_id, presence: true
  
  default_scope order: 'updated_at desc'
  
  def level
    enrollments = persona.paths.joins(:enrollments).where("enrollments.user_id = ?", user.id).select("enrollments.total_points")
    return 1 if enrollments.empty?
    levels = enrollments.to_a.inject(0) { |count, e| e.total_points.to_i / 300 }
    return levels == 0 ? 1 : levels
  end
end
