class UserAuth < ActiveRecord::Base
  attr_accessible :provider, :uid
  
  belongs_to :user
  
  validates :user_id, presence: true, uniqueness: { scope: :provider }
  validates :provider, presence: true
end
