class SentEmail < ActiveRecord::Base
  attr_accessible :user_id, :content
  
  validates_presence_of :user_id
end