class Vote < ActiveRecord::Base
  attr_readonly :owner_id, :owner_type
  
  belongs_to :owner, polymorphic: true
  belongs_to :user
  
  validates :user_id, presence: true
end
