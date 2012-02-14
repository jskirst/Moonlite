class UserAchievement < ActiveRecord::Base
	attr_accessible :achievement_id, :updated_at
	
	belongs_to :user
	belongs_to :achievement
  has_one :path, :through => :achievement
	
	validates :user_id, :presence => true
	validates :achievement_id, :presence => true
	
	default_scope :order => 'updated_at desc'
  
  validate :user_enrolled_in_path
  
  private
    def user_enrolled_in_path
			unless user.nil? || path.nil? || user.enrolled?(path)
				errors[:base] << "User must be enrolled in the path."
      end
    end
end
