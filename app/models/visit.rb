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
end