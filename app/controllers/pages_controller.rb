class PagesController < ApplicationController
	
	def home
		@title = "Home"
		if signed_in?
			@paths = current_user.enrolled_paths
			@user_achievements = UserAchievement.find(:all, :joins => "JOIN users on user_achievements.user_id = users.id JOIN achievements on achievements.id = user_achievements.achievement_id", 
				:conditions => ["users.company_id = ?", current_user.company_id], :limit => 15)
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
