class PagesController < ApplicationController
	
	def home
		@title = "Home"
		if signed_in?
			@paths = current_user.enrolled_paths
		else
			@paths = []
		end
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
	
	def invitation
		@title = "Request an invite"
		if params[:pages] && params[:pages][:email]
			send_invitation_alert(params[:pages][:email])
			render "invitation_sent"
		end
	end
	
	private
		def send_invitation_alert(email)
			Mailer.invitation_alert(email).deliver
		end
end
