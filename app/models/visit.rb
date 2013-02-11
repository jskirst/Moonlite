class Visit < ActiveRecord::Base
  attr_readonly :user_id, :visitor_id, :request_url
  
  validates_presence_of :request_url
end