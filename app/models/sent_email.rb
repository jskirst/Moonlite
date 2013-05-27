class SentEmail < ActiveRecord::Base
  attr_accessible :user_id, :content
  
  belongs_to :user
  
  validates_presence_of :user_id
  validates_presence_of :content
end