class Visit < ActiveRecord::Base
  attr_readonly :user_id, :visitor_id, :request_url
  attr_protected :updated_at, :external_id
  
  belongs_to :user
  
  validates_presence_of :request_url
  validates_presence_of :external_id
  
  before_validation do 
    self.request_url = self.request_url.slice(0..255) if request_url.length >= 255
    self.external_id = SecureRandom.hex(16) unless external_id
  end
end