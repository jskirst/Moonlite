class UserEvent < ActiveRecord::Base
  DEFAULT_IMAGE_LINK = "https://s3.amazonaws.com/moonlite-nsdub/static/stoney+100x150.png"
  BASE_URL = "http://www.metabright.com/"
  attr_accessible :actioner_id, :content, :link, :image_link, :is_read
  
  scope :unread, where(is_read: false)
  belongs_to :user
  belongs_to :actioner, class_name: "User"

  validates_presence_of :link
  validates :content, length: { within: 1..140 }
  
  before_create { self.image_link ||= DEFAULT_IMAGE_LINK }
  
  def self.log_event(reciever, content, actioner = nil, link = nil, image_link = nil)
    return false if actioner == reciever
    actioner_id = actioner ? actioner.id : nil
    e = reciever.user_events.new(actioner_id: actioner_id)

    e.link = link || "#"
    e.image_link = image_link
    e.content = content
    e.save!
  end
  
  def self.log_point_event(user, enrollment, event_type)
    path = enrollment.path
    path_url = BASE_URL + "challenges/#{path.permalink}"
    if event_type == :contribution_unlocked
      content = "You have unlocked the ability to contribute your own questions to the #{path.name} Challenge!"
      log_event(user, content, nil, path_url, path.picture)
    end
  end
end
