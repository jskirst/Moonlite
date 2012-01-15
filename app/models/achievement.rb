class Achievement < ActiveRecord::Base
	attr_accessible :name, :description, :criteria, :points, :path_id
	
	belongs_to :path
	
	validates :name, 
		:presence 		=> true,
		:length			=> { :within => 1..255 }
	
	validates :description, 
		:presence 		=> true,
		:length			=> { :within => 1..255 }
		
	validates :criteria,
		:presence 		=> true
	
	validates :points, 
		:presence 		=> true
		
	validates :path_id, :presence => true
	
	default_scope :order => 'points ASC'
end
