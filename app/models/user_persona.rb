class UserPersona < ActiveRecord::Base
  attr_accessible :persona_id, :updated_at
  
  belongs_to :user
  belongs_to :persona
  
  validates :user_id, presence: true, uniqueness: { scope: :persona_id }
  validates :persona_id, presence: true
  
  default_scope order: 'updated_at desc'
  
  def level
    paths = persona.paths.select("paths.id").all
    paths = paths.to_a.collect &:id
    enrollments = user.enrollments.where("path_id in (?)", paths)
    return 1 if enrollments.empty?
    return enrollments.to_a.inject(0) { |count, e| e.level }
  end
end
