class Topic < ActiveRecord::Base
  attr_readonly :path_id
  attr_accessible :name, :path_id
  
  belongs_to  :path
  has_many    :tasks
  
  validates_presence_of :path_id
  validates_presence_of :name
end