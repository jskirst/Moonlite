class PhrasePairing < ActiveRecord::Base
	attr_accessible :phrase_id, :paired_phrase_id, :strength
	
	belongs_to :phrase
	belongs_to :paired_phrase, :class_name => :phrase
	
	validates :phrase_id, :presence => true
	validates :paired_phrase_id, :presence => true
	
	default_scope :order => 'strength desc'
	
	def self.create_phrase_pairings(new_phrases)
    phrases = []
    new_phrases.each do |np|
      phrases << Phrase.find_or_create_by_content(np.downcase)
    end
    phrases.each do |p|
      phrases.each do |pp|
        unless pp == p
          pairing = PhrasePairing.find_or_create_by_phrase_id_and_paired_phrase_id(p.id, pp.id)
          pairing.strength += 1
          pairing.save
        end
      end
    end
  end
end