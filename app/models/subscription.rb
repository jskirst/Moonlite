class Subscription < ActiveRecord::Base
  attr_readonly :followed_id, :follower_id
  
  belongs_to :followed, class_name: "User"
  belongs_to :follower, class_name: "User"
end