class CopyContentIntoOriginalContentOnPhrase < ActiveRecord::Migration
	def change
		Phrase.where("original_content is ?", nil).each do |p|
			p.original_content = p.content.capitalize
			p.save
		end
	end
end
