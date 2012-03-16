class PhrasePairing < ActiveRecord::Base
	attr_accessible :phrase_id, :paired_phrase_id, :strength
	
	belongs_to :phrase
	belongs_to :paired_phrase, :class_name => :phrase
	
	validates :phrase_id, :presence => true
	validates :paired_phrase_id, :presence => true
	
	default_scope :order => 'strength desc'
end
