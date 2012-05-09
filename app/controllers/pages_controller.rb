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
      @user_events = UserEvent.includes(:user, :company, :path).where("companies.id = ? and users.user_role_id = ?", current_user.company_id, current_user.user_role_id).all(:limit => 20, :order => "user_events.created_at DESC")
		else
			render "landing"
		end
	end
  
  def explore
		@title = "Explore"
    @path_categories = []
    @display_all = true
    if params[:search]
      @query = params[:search]
      @path_categories << [Category.new(:name => "Search Results"), Path.with_name_like(@query, current_user)]
    elsif params[:c]
      category = current_user.company.categories.find(params[:c])
      if category.nil?
        flash[:error] = "Invalid Path category."
        redirect_to explore_path and return
      else
        @path_categories << [category, Path.with_category(c.id, current_user)]
      end
    else
      @display_all = true
      categories = Category.find_all_by_company_id(current_user.company_id)
      categories.each do |c|
        @path_categories << [c, Path.with_category(c.id, current_user)]
      end
    end
		logger.debug @path_categories
	end
	
	def create
		if @enable_collaboration
			@published_paths = current_user.company.paths.where("is_published = ?", true).all(:order => "updated_at DESC")
			@unpublished_paths = current_user.company.paths.where("is_published = ?", false).all(:order => "updated_at DESC")
		else
			@published_paths = current_user.paths.where("is_published = ?", true).all(:order => "updated_at DESC")
			@unpublished_paths = current_user.paths.where("is_published = ?", false).all(:order => "updated_at DESC")
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
	
	def tutorial
		@path = Path.find(params[:p])
		unless current_user.enrolled?(@path)
			flash[:info] = "You must first enroll in challenge before you can start it."
			redirect_to root_path and return
		end
	end
	
	private
		def send_invitation_alert(email)
			Mailer.invitation_alert(email).deliver
		end
		
		def user_creation_enabled?
			unless @enable_user_creation
				flash[:error] = "You do not have access to this functionality."
				redirect_to root_path
			end
		end
		
		def browsing_enabled?
			unless @enable_browsing
				flash[:error] = "You do not have access to this functionality."
				redirect_to root_path
			end
		end
end
