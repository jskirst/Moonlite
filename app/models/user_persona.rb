class UserPersona < ActiveRecord::Base
  attr_accessible :persona_id, :updated_at
  
  belongs_to :user
  belongs_to :persona
  belongs_to :path
  
  validates :user_id, presence: true, uniqueness: { scope: :persona_id }
  validates :persona_id, presence: true
  validate do errors[:base] << "Must be enrolled."unless user.enrolled?(path) end
  
  default_scope order: 'updated_at desc'
end
