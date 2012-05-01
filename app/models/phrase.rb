class Phrase < ActiveRecord::Base
	attr_accessible :content, :original_content
	before_create :downcase
  
  has_many :phrase_pairings
	
	validates :content, 
		:presence 	=> true,
		:length			=> { :within => 1..255 }
		
	def self.search(str)
		#return Phrase.where(["content LIKE :str", {:str => str}]).first
		phrase = Phrase.find(:first, :conditions => ['content LIKE ?', "#{str}%"])
		phrase = Phrase.find(:first, :conditions => ['content LIKE ?', "%#{str}%"]) if phrase.nil?
		return phrase
	end
    
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
