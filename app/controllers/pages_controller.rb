class PagesController < ApplicationController
	
	def home
		@title = "Home"
		if signed_in?
			@paths = current_user.enrolled_paths
		else
			@paths = []
		end
	end

	def contact
		@title = "Contact"
	end
	
	def news
		@title = "News"
	end
  
	def about
		@title = "About"
	end
	
	def help
		@title = "Help"
	end
	
	def all_paths
		@title = "All Paths"
		@paths = Path.paginate(:page => params[:page])
	end

end
