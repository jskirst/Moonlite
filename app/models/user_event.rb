class UserEvent < ActiveRecord::Base
  DEFAULT_IMAGE_LINK = "https://s3.amazonaws.com/moonlite-nsdub/static/stoney+100x150.png"
  attr_accessible :actioner_id, :content, :link, :image_link, :is_read
  
  belongs_to :user
  belongs_to :actioner, class_name: "User"

  validates_presence_of :link
  validates :content, length: { within: 1..140 }
  
  before_create { self.image_link ||= DEFAULT_IMAGE_LINK }
end
