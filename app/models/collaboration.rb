class Collaboration < ActiveRecord::Base
  attr_protected  :path_id
  attr_accessible :granting_user_id, :user_id
  
  belongs_to :path
  belongs_to :user
  belongs_to :granting_user, :class_name => "User"
  
  validates :path_id, :presence => true
  validates :user_id, :presence => true
  validates :granting_user_id, :presence => true
  
  validate :granting_user_can_grant_collaboration
  validate :user_can_collaborate
  validate :check_for_duplicate
  
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
  
    def check_for_duplicate
      if Collaboration.find_by_path_id_and_user_id(self.path_id, self.user_id)
        errors[:base] << "This user has already been given access."
      end
    end
end
