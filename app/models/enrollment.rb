class Enrollment < ActiveRecord::Base
	attr_accessible :path_id
	
	belongs_to :user
	belongs_to :path
	
	validates :user_id, :presence => true, :uniqueness => { :scope => :path_id }
	validates :path_id, :presence => true, :uniqueness => { :scope => :user_id }
end
