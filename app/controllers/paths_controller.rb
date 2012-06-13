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
    @title = "New #{name_for_paths}"
  end

  def create
    params[:path][:user_id] = current_user.id
    @path = current_user.company.paths.build(params[:path])
    if @path.save
      flash[:success] = "#{name_for_paths} created."
      redirect_to new_section_path(:path_id => @path.id)
    else
      @title = "New #{name_for_paths}"
      @categories = current_user.company.categories
      render 'new'
    end
  end

# Begin Path Editing  
  
  def edit
    if @path.sections.empty?
      redirect_to new_section_path(:path_id => @path.id)
      return
    end
    @title = "Edit"
    @categories = current_user.company.categories
    @file_upload_possible = @path.sections.size == 0 ? true : false
    @mode = params[:m]
    if @mode == "settings"
      render "edit_settings"
    elsif @mode == "achievements" && @enable_achievements
      @achievements = @path.achievements
      render "edit_achievements"
    elsif @mode == "access_control"
      raise "Path and current user belong to different companies. Path company id: #{@path.company_id}. User company id: #{current_user.company.id}" if @path.company.id != current_user.company.id
      raise "Path company user roles and current user company user roles are different." if @path.company.user_roles != current_user.company.user_roles
      @user_roles = @path.company.user_roles
      @path_user_roles = [] 
      @path.user_roles.each { |pur| @path_user_roles << pur.id }
      render "edit_roles"
    else
      @sections = @path.sections
      @categories = current_user.company.categories
      render "edit"
    end
  end
  
  def update
    params[:path].delete("image_url") if params[:path][:image_url].blank?
    begin
      if @path.update_attributes(params[:path])
        flash[:success] = "Changes saved."
      else
        flash[:error] = "Error occurred: "+@path.errors.full_messages.join(". ")
      end
    rescue
      flash[:error] = "An error prevented your changes from being saved. Please try again."
    end
    redirect_to edit_path_path(@path)
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
  
  def update_roles
    @path = current_user.company.paths.find(params[:id])
    all_roles = current_user.company.user_roles
    allowed_roles = []
    unless params[:path].nil?
      params[:path][:user_roles].each do |id, status|
        allowed_roles << id
      end
    end
    
    all_roles.each do |r|
      path_user_role = @path.path_user_roles.find_by_user_role_id(r.id)
      if allowed_roles.include?(r.id.to_s)
        new_role = @path.path_user_roles.create!(:user_role_id => r.id) if path_user_role.nil?
      else
        @path.path_user_roles.delete(path_user_role) unless path_user_role.nil?
      end
    end
    flash[:success] = "Path access control updated."
    redirect_to edit_path_path(:id => @path, :m => "access_control")
  end
  
  def publish
    if @path.sections.where(["is_published = ?", true]).count.zero?
      flash[:error] = "You need to publish at least one section before you can make your challenge publicly available."
    elsif @path.default_pic?
      flash[:info] = "You need to set a custom picture for your #{name_for_paths} before you can publish it. You can do that by clicking the Settings button."
    elsif @path.description.blank?
      flash[:info] = "You need to create a description for your #{name_for_paths} before you can publish it. You can do that by clicking the Settings button."
    else
      @path.sections.each do |s|
        s.update_attribute(:is_published, true)
      end
      current_user.company.user_roles.each do |ur|
        if @path.user_roles.find_by_id(ur.id).nil?
          @path.path_user_roles.create!(:user_role_id => ur.id)
        end
      end
      @path.is_published = true
      @path.is_public = true
      if @path.save
        flash[:success] = "#{@path.name} has been successfully published. It is now visible to the #{ company_logo } community."
      else
        flash[:error] = "There was an error publishing."
      end
    end
    redirect_to edit_path_path(@path)
  end
  
  def unpublish
    @path.is_published = false
    if @path.save
      flash[:success] = "#{name_for_paths} has been unpublished and is no longer visible."
    else
      flash[:error] = "Oops, could not unpublish this #{name_for_paths}. Please try again."
    end
    redirect_to edit_path_path(@path)
  end

  def destroy
    @path.destroy
    flash[:success] = "#{name_for_paths} successfully deleted."
    redirect_back_or_to root_path
  end

# Begin Path Journey

  def show
    @title = @path.name
    @sections = @path.sections.find(:all, :conditions => ["sections.is_published = ?", true])
    
    if @enable_leaderboard
      @leaderboards = Leaderboard.get_leaderboards_for_path(@path, current_user)
      @last_update = Leaderboard.get_most_recent_board_date
    end
    
    @current_position = @path.current_section(current_user).position unless @sections.empty?
    @enrolled = current_user.enrolled?(@path)
    if current_user.path_started?(@path)
      @start_mode = @path.completed?(current_user) ? "View Score" : "Continue Challenge"
    elsif current_user.enrolled?(@path)
      @start_mode = "Start #{name_for_paths}"
    else
      @start_mode = "Enroll"
    end
  end
  
  def jumpstart
    @company = Company.find(1)
    @path = @company.paths.find(params[:id])
    unless signed_in?
      store_location
      @user = User.create_anonymous_user(@company)
      sign_in(@user)
      @user.enrollments.create!(:path_id => @path.id)
      if(ab_test :slow_start_v2)
        redirect_to @path
        return
      end
    end
    redirect_to continue_path_path(@path)
  end
  
  def continue
    @section = current_user.most_recent_section_for_path(@path)
    until @section.nil? || !@section.completed?(current_user)
      @section = @path.next_section(@section)
    end
    
    unless @section.nil? || @section.is_published == false
      if @section.instructions.blank? && @section.info_resources.empty?
        redirect_to continue_section_path(@section)
      else
        redirect_to @section
      end
    else
      redirect_to finish_path_path(@path)
    end
  end
  
  def finish
    store_location #So user will be redirected here after registration
    @must_register = current_user.must_register?
    @total_points_earned = @path.enrollments.where("enrollments.user_id = ?", current_user.id).first.total_points
    
    previous_ranking = Leaderboard.reset_for_path_user(@path, current_user)
    track! :path_completion if previous_ranking.nil?
    
    @skill_ranking = @path.skill_ranking(current_user)
    @leaderboards = Leaderboard.get_leaderboards_for_path(@path, current_user, false).first
    counter = 1
    previous = nil
    @leaderboards[1].each do |l|
      if l.user_id == current_user.id
        @next_rank_points = (counter == 1 ? 0 : previous.score - l.score + 1)
        @user_rank = ActiveSupport::Inflector::ordinalize(counter)
        break
      else
        previous = l
        counter += 1
      end
    end
    
    @similar_paths = Path.similar_paths(@path, current_user)
    if current_user.user_events.where("path_id = ? and content LIKE ?", @path.id, "%completed%").empty?
      event = "<%u%> completed the <%p%> #{name_for_paths} with a score of #{@total_points_earned.to_s}."
      current_user.user_events.create!(:path_id => @path.id, :content => event)
    end
  end

  private
    def get_path_from_id
      if !@path = Path.find_by_id(params[:id])
        flash[:error] = "No #{name_for_paths} found for the argument supplied."
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
        flash[:error] = "You do not have access to this #{name_for_paths}. Please contact your administrator to gain access."
        redirect_to root_path
      end
    end
    
    def can_view?
      redirect_to root_path unless (@path.is_published && @path.user_roles.find_by_id(current_user.user_role.id) && !@path.is_locked) || (@path.user_id = current_user.id) || (@path.company_id == current_user.company_id && @enable_collaboration)
    end
    
    def can_continue?
      redirect_to root_path unless current_user.enrolled?(@path)
    end
end