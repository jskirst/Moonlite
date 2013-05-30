class GroupUser < ActiveRecord::Base
  attr_accessor :is_admin
  attr_protected :is_admin
  attr_readonly :group_id, :user_id
  
  after_save :flush_cache
  before_destroy :flush_cache
  
  belongs_to  :user, touch: true
  belongs_to  :group
  
  validates_presence_of :group_id
  validates_presence_of :user_id
  
  def flush_cache
    Rails.cache.delete(["Group", "user", user_id])
  end
end