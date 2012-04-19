class PagesController < ApplicationController
	before_filter :authenticate, :only => [:explore]
	before_filter :user_creation_enabled?, :only => [:create]
	before_filter :browsing_enabled?, :only => [:explore]
  
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
			if @enable_recommendations
				@suggested_paths = Path.suggested_paths(current_user)				
			end
      @user_achievements = UserAchievement.find(:all, :joins => "JOIN users on user_achievements.user_id = users.id JOIN achievements on achievements.id = user_achievements.achievement_id", 
				:conditions => ["users.company_id = ?", current_user.company_id], :limit => 15)
		else
			render "landing"
		end
	end
  
  def explore
		@title = "Explore"
    @path_categories = []
    @display_all = false
    if params[:search]
      @query = params[:search]
      @path_sections << ["Search Results", Path.with_name_like(@query)]
    elsif params[:c]
      category = current_user.company.categories.find(params[:c])
      if category.nil?
        flash[:error] = "Invalid Path category."
        redirect_to explore_path and return
      else
        @path_categories << [category, Path.with_category(category.id)]
      end
    else
      @display_all = true
      categories = Category.find_all_by_company_id(current_user.company_id)
      categories.each do |c|
        @path_categories << [c, Path.with_category(c.id)]
      end
    end
	end
	
	def create
		@published_paths = current_user.paths.where("is_published = ?", true)
		@unpublished_paths = current_user.paths.where("is_published = ?", false)
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
		
		def user_creation_enabled?
			unless (current_user.admin? || current_user.company_admin? || @enable_user_creation)
				flash[:error] = "You do not have access to this functionality."
				redirect_to root_path
			end
		end
		
		def browsing_enabled?
			unless (current_user.admin? || current_user.company_admin? || @enable_browsing)
				flash[:error] = "You do not have access to this functionality."
				redirect_to root_path
			end
		end
end
