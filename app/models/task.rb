class Task < ActiveRecord::Base
	attr_accessible :question, :answer, :rank, :resource
	
	belongs_to :path
	
	validates :question, 
		:presence 		=> true,
		:length			=> { :within => 1..255 }
	
	validates :answer, 
		:presence 		=> true,
		:length			=> { :within => 1..255 }
		
	validates :rank, 
		:presence 		=> true,
		:numericality	=> { :less_than => 51 }
		
	validates :resource,
		:length			=> { :maximum => 255 }
	
	validates :path_id, :presence => true
	
	default_scope :order => 'tasks.rank ASC'
end
