class Visit < ActiveRecord::Base
  attr_readonly :user_id, :visitor_id, :request_url
  
  belongs_to :user
  
  validates_presence_of :request_url
  
  before_validation { self.request_url = self.request_url.slice(0..255) }
end