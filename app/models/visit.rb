class Visit < ActiveRecord::Base
  attr_readonly :user_id, :visitor_id, :request_url, :referral_url
  attr_protected :updated_at, :external_id
  
  belongs_to :user
  
  validates_presence_of :request_url
  validates_presence_of :external_id
  
  before_validation do 
    self.request_url = self.request_url.slice(0..255) if request_url.length >= 255
    self.external_id = SecureRandom.hex(16) unless external_id
  end
  
  def page
    return "" if request_url.blank?
    return request_url.split("/").last(3).join("/").slice(0..70)
  end
  
  def time_on_page(next_page = nil)
    return next_page.created_at - created_at if next_page
    return updated_at - created_at
  end
  
  def self.profile_views(user, time)
    raise "Time required" unless time
    if Rails.env == "development"
      base_url = "http://localhost:3000/"
    else
      base_url = "http://www.metabright.com/"
    end
    url = base_url+"#{user.username}"
    user_visits = Visit.select("user_id, visitor_id")
      .where("visits.created_at > ?", time)
      .where("user_id is ? or user_id != ?", nil, user.id)
      .where("request_url ILIKE ?", "#{url}%")
      .group("user_id, visitor_id")
      .to_a
  end
  
  def self.send_visit_alerts(user, time, deliver = false)
    views = Visit.profile_views(user, time)
    if views.size > 0
      if views.select{ |v| !v.user_id.nil? }.size > 0 or views.size >= 3
        m = Mailer.visit_alert(user, views)
        m.deliver if deliver
        return m
      else
        puts "Did not mail - not enough visits or 0 user visits"
      end
    end
  end
  
  def self.send_all_visit_alerts(time, deliver = false)
    User.all.each do |user|
      Visit.send_visit_alerts(user, time, deliver)
    end
  end
end