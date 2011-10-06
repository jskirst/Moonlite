module ApplicationHelper
	def title
		base_title = "Sample App"
		if @title.nil?
			base_title
		else
			base_title + " | " + @title
		end
	end
	
	def logo
		image_tag("http://railstutorial.org/images/sample_app/logo.png", :alt => "Sample App", :class => "round")
	end
end
