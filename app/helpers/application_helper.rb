module ApplicationHelper
	def title
		base_title = "Project Moonlite"
		if @title.nil?
			base_title
		else
			base_title + " | " + @title
		end
	end
	
	def logo
		image_tag("logo.png", :alt => "Project Moonlite", :class => "round", :size => "50x50")
	end
end
