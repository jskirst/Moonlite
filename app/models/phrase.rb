class Phrase < ActiveRecord::Base
	attr_accessible :content
	before_create :downcase
  
  has_many :phrase_pairings
	
	validates :content, 
		:presence 	=> true,
		:length			=> { :within => 1..255 }
    
  def associated_phrases
    associated_phrases = []
    phrase_pairings.each do |p|
      associated_phrases << Phrase.find_by_id(p.paired_phrase_id).original_content
    end
    return associated_phrases
  end
  
  def downcase
		self.original_content = self.content
    self.content = self.content.downcase
  end
end
