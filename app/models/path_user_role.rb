class PathUserRole < ActiveRecord::Base
  attr_accessible :user_role_id
  
  belongs_to :path
  belongs_to :user_role
  
  validates :user_role_id, presence: true, uniqueness: { scope: :path_id }
  validates :path_id, presence: true
end
