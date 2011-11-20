class InfoResource < ActiveRecord::Base
	attr_accessible :description, :link
	
	belongs_to :path
	
	validates :description, 
		:presence 		=> true,
		:length			=> { :within => 1..255 }
	
	validates :link, 
		:presence 		=> true,
		:length			=> { :within => 1..255 }
	
	validates :path_id, :presence => true
end
