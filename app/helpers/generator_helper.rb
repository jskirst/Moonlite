module GeneratorHelper
	def clean_text(text)
		return nil if text.nil?
		text = text.gsub("This section will include questions on the following topics", "")
			.gsub("<b>","  ")
			.gsub("</b>","  ")
			.gsub("<sub>","")
			.gsub("</sub>","  ")
			.gsub(/<a[^>]*>/im,"  ")
			.gsub(/<\/a>/im,"  ")
			.gsub(/<li\b[^>]*>(.*?)<\/li>/im," ")
			.gsub(/<!--[^>]*-->/im,"")
			.gsub(/<[\/a-z123456]{2}[^>]*>/im," ")
			.gsub(/<[\/bi][^>]*>/im," ")
			.gsub(/\[[^\]]+\]/im," ")
			.gsub(/\([^\)]+\)/im," ")
			.gsub("&nbsp;"," ")
			.gsub("&quot;","")
			.gsub(/\r\n/," ")
			.gsub(/"/,"'")
		until text.gsub!(/\s\s/,"").nil?
			text = text.gsub(/\s\s/, " ")
		end
		text = text.gsub(" .", ".").gsub(" ,", ",")
		return text.strip.chomp
	end
	
	def split_and_clean_text(text)
		return nil if text.nil?
		paragraphs = text.split("<p>")
		split_paragraphs = []
		paragraphs.each do |p|
			split_paragraph = p.split(". ")
			sentences = []
			split_paragraph.each_index do |si|
				sentence = split_paragraph[si].chomp + "."
				if sentence.length > 35 
					sentences << sentence
				end
				if sentence.length > 160 || sentences.length >= 3
					split_paragraphs << sentences.join(" ")
					sentences = []
				end
			end
			unless sentences.join(" ").length < 80
				split_paragraphs << sentences.join(" ")
			end
		end
		return split_paragraphs
	end
end
