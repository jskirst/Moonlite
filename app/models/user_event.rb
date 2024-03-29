class UserEvent < ActiveRecord::Base
  DEFAULT_IMAGE_LINK = "https://s3.amazonaws.com/moonlite-nsdub/static/stoney+100x150.png"
  attr_accessible :actioner_id, :content, :link, :image_link, :action_text
  
  scope :unread, -> { where read_at: nil }
  belongs_to :user
  belongs_to :actioner, class_name: "User"
  belongs_to :path

  validates_presence_of :link
  validates :content, length: { within: 1..140 }
  
  before_create { self.image_link ||= DEFAULT_IMAGE_LINK }
  
  after_save :flush_cache
  before_destroy :flush_cache
  
  def self.log_event(reciever, content, actioner = nil, link = nil, image_link = nil)
    return false if actioner == reciever
    actioner_id = actioner ? actioner.id : nil
    e = reciever.user_events.new(actioner_id: actioner_id)

    e.link = link || "#"
    e.image_link = image_link
    e.content = content
    e.save!
  end
  
  def self.user_event_icon(event_type)
    if event_type == :hall_of_fame
      return EVENT_ICON_ACHIEVEMENT
    elsif event_type == :new_question
      return EVENT_ICON_EDIT
    elsif event_type == :new_path
      return EVENT_ICON_ANNOUNCEMENT
    end
  end
  
  # Cached methods
  
  def self.cached_find_by_user_id(user_id)
    Rails.cache.fetch([self.to_s, "user", user_id]) do
      UserEvent.where("user_events.user_id = ?", user_id)
        .where(path_id: nil)
        .joins("LEFT JOIN users on user_events.user_id=users.id")
        .select("user_events.*, users.username, users.image_url, users.name")
        .order("user_events.id DESC")
        .limit(15)
        .to_a
    end
  end
  
  def flush_cache
    Rails.cache.delete([self.class.name, "user", user_id])
  end
end
