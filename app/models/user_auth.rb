class UserAuth < ActiveRecord::Base
  attr_accessible :provider, :uid
  
  belongs_to :user
  
  validates :user_id, :presence => true
  validates :provider, :presence => true
end
