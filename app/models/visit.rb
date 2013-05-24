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
  
  def self.profile_views(user, time_period)
    if Rails.env == "development"
      base_url = "http://localhost:3000/"
    else
      base_url = "http://www.metabright.com/"
    end
    url = base_url+"#{user.username}"
    Visit.where("visits.created_at > ?", time_period)
      .where("user_id != ?", user.id)
      .where("request_url = ?", url)
      .select(:user_id)
      .includes(:user)
      .uniq
      .to_a
  end
  
  def self.test_profile_views_email(user, deliver = false)
    views = Visit.profile_views(user, Time.now - 24.hours)
    m = Mailer.visit_alert(user, views)
    m.deliver if deliver
    return m
  end
end