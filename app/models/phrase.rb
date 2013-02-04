class Phrase < ActiveRecord::Base
  attr_accessible :content, :original_content
  
  has_many :phrase_pairings
  
  validates :content, length: { within: 1..255 }
  
  before_create :downcase
    
  def self.search(str)
    phrase = Phrase.where("content LIKE ?", "#{str}%").first
    phrase = Phrase.where("content LIKE ?", "%#{str}%").first if phrase.nil?
    return phrase
  end
    
  def associated_phrases
    return phrase_pairings.each { Phrase.find_by_id(p.paired_phrase_id).original_content }
  end
  
  def downcase
    self.original_content = self.content
    self.content = self.content.downcase
  end
end
