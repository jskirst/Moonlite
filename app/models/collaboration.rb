class Collaboration < ActiveRecord::Base
  attr_protected  :path_id
  attr_readonly :granting_user_id, :user_id
  
  belongs_to :path
  belongs_to :user
  belongs_to :granting_user, class_name: "User"
  
  validates :path_id, presence: true, uniqueness: { scope: [:user_id, :granting_user_id] }
  validates :user_id, presence: true
  validates :granting_user_id, presence: true
  
  validate :granting_user_can_grant_collaboration
  validate :user_can_collaborate
  
  private
    def granting_user_can_grant_collaboration
      if !granting_user.user_role.enable_user_creation
        errors[:base] << "You must be able to create to add collaborators."
      elsif self.granting_user_id != path.user_id
        errors[:base] << "Only creators can add additional collaborators."
      end
    end
    
    def user_can_collaborate
      if !user.user_role.enable_user_creation
        errors[:base] << "You must be able to create to become a collaborator."
      elsif user.company_id != path.company_id
        errors[:base] << "Cross organization access is not allowed."
      end
    end
end
