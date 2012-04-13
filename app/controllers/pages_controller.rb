class PagesController < ApplicationController
	before_filter :authenticate, :only => [:explore]
  
	def home
		@title = "Home"
		if signed_in?
			@paths = current_user.enrolled_paths
      @enrolled_paths = []
      @completed_paths = []
      @paths.each do |p|
        if p.completed?(current_user)
          @completed_paths << p
        else
          @enrolled_paths << p
        end
      end
      @suggested_paths = Path.suggested_paths(current_user)
      @user_achievements = UserAchievement.find(:all, :joins => "JOIN users on user_achievements.user_id = users.id JOIN achievements on achievements.id = user_achievements.achievement_id", 
				:conditions => ["users.company_id = ?", current_user.company_id], :limit => 15)
		else
			render "landing"
		end
	end
  
  def explore
		@title = "Explore"
    @path_sections = []
    @display_all = false
    if params[:search]
      @query = params[:search]
      @path_sections << ["Search Results", Path.with_name_like(@query)]
    elsif params[:m]
      type_name = params[:m]
      type = Path.get_category_type_id(type_name)
      if type.nil?
        flash[:error] = "Invalid Path category type."
        redirect_to explore_path and return
      else
        @path_sections << [type_name, Path.with_category_type(type)]
      end
    else
      @display_all = true
      categories = Category.find_all_by_company_id(current_user.company_id)
      categories.each do |c|
        @path_sections << [c.name, Path.with_category(c.id)]
      end
      
      unpublished_paths = current_user.paths.where("is_published = ?", false)
      unless unpublished_paths.empty?
        @path_sections << ["Unpublished Paths", unpublished_paths]
      end
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
