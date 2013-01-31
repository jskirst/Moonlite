class NotificationSettings < ActiveRecord::Base
  attr_readonly :user_id
  attr_accessible :user_id, :weekly, :powers, :interaction, :inactive
  
  validates :user_id, presence: true
  
  belongs_to :user
end