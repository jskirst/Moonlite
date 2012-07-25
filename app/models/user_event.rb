class UserEvent < ActiveRecord::Base
  attr_accessible :path_id, :content
  
  belongs_to :user
  belongs_to :path
  has_one :company, :through => :user
  
  validates :user_id, :presence => true
  validates :path_id, :presence => true
  
  validates :content, length: { within: 1..140 }
  validate do errors[:base] << "Must be enrolled."unless user.enrolled?(path) end
end
