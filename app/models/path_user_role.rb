class PathUserRole < ActiveRecord::Base
  attr_accessible :user_role_id
  
  belongs_to :path
  belongs_to :user_role
  
  validates :user_role_id, :presence => true
  validates :path_id, :presence => true
  validate :check_for_duplicate
  
  private
    def check_for_duplicate
      if PathUserRole.find_by_path_id_and_user_role_id(self.path_id, self.user_role_id)
        errors[:base] << "This user role has already been given access."
      end
    end
end
