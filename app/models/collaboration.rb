class Collaboration < ActiveRecord::Base
  attr_protected  :path_id
  attr_readonly :granting_user_id, :user_id
  
  belongs_to :path
  belongs_to :user
  belongs_to :granting_user, class_name: "User"
  
  validates :path_id, presence: true, uniqueness: { scope: [:user_id, :granting_user_id] }
  validates :user_id, presence: true
  validates :granting_user_id, presence: true
end
