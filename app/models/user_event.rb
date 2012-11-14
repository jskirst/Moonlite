class UserEvent < ActiveRecord::Base
  attr_accessible :actioner_id, :content, :link, :image_link, :is_read
  
  belongs_to :user
  belongs_to :actioner, class_name: "User"

  validates_presence_of :link
  validates_presence_of :image_link
  validates :content, length: { within: 1..140 }
end
