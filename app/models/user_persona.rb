class UserPersona < ActiveRecord::Base
  attr_accessible :persona_id, :updated_at
  
  belongs_to :user
  belongs_to :persona
  belongs_to :path
  
  validates :user_id, presence: true, uniqueness: { scope: persona_id }
  validates :persona_id, presence: true, uniqueness: { scope: user_id }
  validate :user_enrolled_in_path
  
  default_scope order: 'updated_at desc'
  
  
  
  private
    def user_enrolled_in_path
      unless user.nil? || path.nil? || user.enrolled?(path)
        errors[:base] << "User must be enrolled in the path."
      end
    end
end
