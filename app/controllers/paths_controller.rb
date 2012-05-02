class PathsController < ApplicationController
  include OrderHelper
  
	before_filter :authenticate, :except => [:hero, :jumpstart]
	before_filter :get_path_from_id, :except => [:index, :new, :create]
	before_filter :can_create?, :only => [:new, :create]
	before_filter :can_edit?, :only => [:edit, :update, :reorder_sections, :destroy]
	before_filter :can_view?, :only => [:show]
	before_filter :can_continue?, :only => [:continue]
  
# Begin Path Creation
	
	def new
		@path = Path.new
    @categories = current_user.company.categories
		@title = "New Path"
	end

	def create
		params[:path][:company_id] = current_user.company.id
		@path = current_user.paths.build(params[:path])
		if @path.save
			flash[:success] = "Challenge created."
			redirect_to edit_path_path(@path, :m => "start")
		else
			@title = "New Challenge"
      @categories = current_user.company.categories
			render 'new'
		end
	end

# Begin Path Editing  
  
	def edit
		@title = "Edit"
		@categories = current_user.company.categories
    @file_upload_possible = @path.sections.size == 0 ? true : false
    @mode = params[:m]
		if params[:m] == "settings"
			render "edit_settings"
		elsif params[:m] == "achievements" && @enable_achievements
			@achievements = @path.achievements
			render "edit_achievements"
		else
      @start_mode = true if @mode == "start"
      @mode = "sections"
    	@sections = @path.sections
      if params[:a] == "reorder"
        @reorder = true
      end
      render "edit_sections"
    end
	end
	
	def update
		if params[:path][:image_url].blank?
			params[:path].delete("image_url")
		end
    if params[:path][:is_published] == "1"
      if @path.sections.where(["is_published = ?", true]).count.zero?
        flash[:error] = "You need to publish at least one section before you can make your challenge publicly available."
        render 'edit' 
        return
      end
    end
		if @path.update_attributes(params[:path])
			flash[:success] = "Changes saved."
			redirect_to edit_path_path(@path)
		else
			@title = "Edit Challenge"
			render 'edit'
		end
	end
  
  def reorder_sections
    old_order = @path.sections.map { |s| [s.id, s.position] }
    new_order = params[:sections][:positions].map { |id, position| [id.to_i, position.to_i] }
    revised_order = reorder(old_order, new_order)
    revised_order.each do |s|
      @path.sections.find(s[0]).update_attribute(:position, s[1])
    end
    redirect_to edit_path_path(@path, :m => "sections")
  end

  def destroy
		@path.destroy
		flash[:success] = "Path successfully deleted."
		redirect_back_or_to root_path
	end

# Begin Path Journey

  def show
		@title = @path.name
		#@achievements = @path.achievements.all(:limit => 20)
    #@enrolled_users = @path.enrolled_users.all(:limit => 20)
		@sections = @path.sections.find(:all, :conditions => ["sections.is_published = ?", true])
		
		if @enable_leaderboard
			@leaderboards = Leaderboard.get_leaderboards_for_path(@path)
			@last_update = Leaderboard.get_most_recent_board_date
		end
		
    @current_position = @path.current_section(current_user).position unless @sections.empty?
    @enrolled = current_user.enrolled?(@path)
    if current_user.path_started?(@path)
      @start_mode = @path.completed?(current_user) ? "View Score" : "Continue Challenge"
    elsif current_user.enrolled?(@path)
      @start_mode = "Get Started"
    else
      @start_mode = "Enroll"
    end
	end
  
	def continue
		@section = current_user.most_recent_section_for_path(@path)
    until @section.nil? || !@section.completed?(current_user)
      @section = @path.next_section(@section)
    end
    if @section.nil? || @section.is_published == false
      @total_points_earned = @path.enrollments.where("enrollments.user_id = ?", current_user.id).first.total_points
      @similar_paths = Path.similar_paths(@path)
      @suggested_paths = Path.suggested_paths(current_user, @path.id)
			if current_user.user_events.where("path_id = ? and content LIKE ?", @path.id, "%completed%").empty?
				event = "<%u%> completed the <%p%> challenge with a score of #{@total_points_earned.to_s}."
				current_user.user_events.create!(:path_id => @path.id, :content => event)
			end
      render "completion"
    else
			if @section.enable_skip_content
				redirect_to continue_section_path(@section)
			else
				redirect_to @section
			end
    end
	end

  def hero
    @title = @path.name
    @user_hero = User.find_by_id(params[:hero])
    @hero_score = @user_hero.enrollments.where("path_id = ?", @path.id).first.total_points
    @other_completed_paths = @user_hero.enrollments.includes(:path).where("paths.id != ?", @path.id).all
    @info_resources = @path.info_resources(:limit => 5)
		@achievements = @path.achievements.all(:limit => 5)
    @sections = @path.sections.find(:all, :conditions => ["sections.is_published = ?", true])
  end
  
  def jumpstart
    @company = Company.find(1)
    @path = @company.paths.find(params[:id])
    @user_roll = @company.user_rolls.find(2)
    if !signed_in?
      @user = User.create_anonymous_user(@company, @user_roll)
      sign_in(@user)
    end
    redirect_to continue_path_path(@path)
  end

	private
		def get_path_from_id
			if !@path = Path.find_by_id(params[:id])
				flash[:error] = "No path found for the argument supplied."
				redirect_to root_path and return
			end
		end
		
		def can_create?
			unless @enable_user_creation
				flash[:error] = "You do not have the ability to create new challenges."
				redirect_to root_path
			end
		end
		
		def can_edit?
			unless can_edit_path(@path)
				flash[:error] = "You do not have access to this Path. Please contact your administrator to gain access."
				redirect_to root_path
			end
		end
		
		def can_view?
			redirect_to root_path unless @path.is_published && @path.company_id == current_user.company_id
		end
		
		def can_continue?
			redirect_to root_path unless current_user.enrolled?(@path)
		end
end