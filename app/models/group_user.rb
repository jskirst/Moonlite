class GroupUser < ActiveRecord::Base
  attr_accessor :is_admin
  attr_protected :is_admin
  attr_readonly :group_id, :user_id
  
  belongs_to  :user
  belongs_to :group
  
  validates_presence_of :group_id
  validates_presence_of :user_id
  
end