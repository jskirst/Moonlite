class PathsController < ApplicationController
  include OrderHelper
  
  before_filter :authenticate, except: [:show]
  before_filter :admin_only, :only => [:index]
  before_filter :get_path_from_id, :except => [:index, :new, :create]
  before_filter :can_create?, :only => [:new, :create]
  before_filter :can_edit?, :only => [:edit, :update, :reorder_sections, :destroy, :collaborator, :collaborators]
  
# Begin Path Creation
  
  def new
    @path = Path.new
    @categories = current_user.company.categories
    @title = "New #{name_for_paths}"
    if params[:type] == "question"
      @path.is_question = true
      render "new_question"
    end
  end

  def create
    @path = current_user.company.paths.new(params[:path])
    @path.user_id = current_user.id
    @path.is_approved = false
    @path.is_published = false
    if @path.save
      if params[:stored_resource_id]
        sr = StoredResource.find(params[:stored_resource_id])
        raise "FATAL: STEALING RESOURCE" if sr.owner_id
        sr.owner_id = @path.id
        sr.owner_type = @path.class.to_s
        sr.save
      end
      redirect_to new_section_path(:path_id => @path.id)
    else
      @categories = current_user.company.categories
      render 'new'
    end
  end

# Begin Path Editing  
  
  def edit
    store_location
    @path.reload
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
      @user_roles = @path.company.user_roles
      @path_user_roles = [] 
      @path.user_roles.each { |pur| @path_user_roles << pur.id }
      render "edit_roles"
    else
      @sections = @path.sections.includes({ :tasks => :answers })
      @categories = current_user.company.categories
      render "edit"
    end
  end
  
  def update
    params[:path].delete("image_url") if params[:path][:image_url].blank?
    params[:path].delete("is_approved")
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
        if params[:commit] = "Save & Enroll"
          r.users.each {|u| u.enroll!(@path) }
        end
      else
        @path.path_user_roles.delete(path_user_role) unless path_user_role.nil?
      end
    end
    flash[:success] = "Path access control updated."
    redirect_to edit_path_path(:id => @path, :m => "access_control")
  end
  
  def publish
    if @path.default_pic?
      flash[:info] = "You need to set a custom picture for your #{name_for_paths} before you can publish it. You can do that by clicking the Settings button."
    elsif @path.description.blank?
      flash[:info] = "You need to create a description for your #{name_for_paths} before you can publish it. You can do that by clicking the Settings button."
    else
      @path.sections.each { |s| s.update_attribute(:is_published, true) }
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

  def collaborators
    @collaborators = @path.collaborating_users
    @collaborator = @path.collaborations.new
  end

  def collaborator
    @collaborators = @path.collaborating_users
    flash[:error] = "No collaborator stated."and render "collaborators" and return if params[:collaborator].nil?
    
    @user = User.find_by_email(params[:collaborator][:email])
    flash[:error] = "User does not exist." and render "collaborators" and return if @user.nil?
    params[:collaborator][:user_id] = @user.id
    params[:collaborator][:granting_user_id] = current_user.id
    
    @collaborator = @path.collaborations.new(params[:collaborator])
    if @collaborator.save
      flash.now[:success] = "#{@user.name} successfully added as a collaborator."
    else
      flash.now[:error] = @collaborator.errors.full_messages.join(". ")
      render "collaborators" and return
    end
    redirect_to collaborators_path_path(@path)
  end

  def undo_collaboration
    @collaboration = @path.collaborations.find_by_user_id(params[:user_id])
    if @collaboration.destroy
      flash[:sad_success] = "User will no longer have access."
    else
      flash[:error] = @collaboration.errors.full_messages.join(". ")
    end
    redirect_to collaborators_path_path(@path)
  end

# Begin Path Journey

  def enroll
    unless current_user.enrolled?(@path)
      current_user.enroll!(@path)
    end
    
    if current_user.earned_points == 0
      redirect_to continue_path_path(@path)
    else
      redirect_to path_path(@path)
    end
  end
  
  def continue
    unless current_user.enrolled?(@path)
      current_user.enroll!(@path)
    end
    @section = current_user.most_recent_section_for_path(@path) || @path.sections.first
    while @section && @section.completed?(current_user)
      @section = @path.next_section(@section)
    end
    
    if @section.nil? || @section.is_published == false
      Leaderboard.reset_for_path_user(@path, current_user)
      redirect_to @path
    else
      redirect_to continue_section_path(@section)
    end
  end
  
  def show
    @leaderboards = Leaderboard.get_leaderboards_for_path(@path, false).first[1]
    @enrolled_users = @path.enrolled_users.limit(15)
    @tasks = @path.tasks
    @votes = []
    
    if current_user
      @enrollment = current_user.enrolled?(@path) || current_user.enrollments.create(path_id: @path.id)
      @total_points_earned = @enrollment.total_points
      @skill_ranking = @enrollment.skill_ranking
      @level_achieved = @enrollment.level
    
      @current_section = current_user.most_recent_section_for_path(@path)
      @unlocked = @current_section.unlocked?(current_user)
    
      @next_rank_points, @user_rank = get_rank_and_next_points(@leaderboards)
    
      @votes = current_user.votes.to_a.collect {|v| v.submitted_answer_id }
      @display_launchpad = params[:completed]
    end
    @page = params[:page].to_i
    offset = @page * 30
    if params[:submission]
      @responses = @path.completed_tasks.joins(:submitted_answer).offset(offset).limit(30).where("submitted_answers.id = ?", params[:submission])
      @sharing = true
    elsif params[:task]
      @responses = @path.completed_tasks.joins(:submitted_answer).offset(offset).limit(30).where("completed_tasks.task_id = ?", params[:task]).order("total_votes DESC")
    elsif params[:order] && params[:order] == "votes"
      @responses = @path.completed_tasks.joins(:submitted_answer).offset(offset).limit(30).all(order: "total_votes DESC")
    else
      @responses = @path.completed_tasks.joins(:submitted_answer).offset(offset).limit(30).all(order: "completed_tasks.created_at DESC")
    end
    @more_available = @responses.size == 30
    @activity_stream = @path.activity_stream
    
    @social_title = @path.name
    @social_description = @path.description
    @social_image = @path.path_pic
    
    if request.xhr?
      render partial: "shared/newsfeed", locals: { newsfeed_items: @responses }
    else
      render "show"
    end
  end
  
# Administration #
  
  def dashboard
    @page = params[:page] || 1
    @time = (params[:time] || 7).to_i
    @mode = params[:mode] || "statistics"
    if @mode == "statistics"
      @user_points, @activity_over_time, @path_score = calculate_path_statistics(@path, @time)
    elsif @mode == "tasks"
      @unresolved_tasks = @path.completed_tasks.includes(:submitted_answer).where("status_id = ?", 2).paginate(:page => params[:page], :per_page => 80)
    elsif @mode == "users"
      @enrolled_users = @path.enrolled_users
      @enrollment = params[:user] ? @path.enrollments.find_by_user_id(params[:user]) : @path.enrollments.first
      @user = @enrollment.user
      @responses = @user.completed_tasks.joins({:task => { :section => :path}}).where("paths.id = ?", @path.id)
      @percentage_correct = @path.percentage_correct(@user)
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
    
    def get_rank_and_next_points(leaderboards)
      counter = 1
      previous = nil
      user_rank = nil
      next_rank_points = nil
      leaderboards.each do |l|
        if l.user_id == current_user.id
          user_rank = ActiveSupport::Inflector::ordinalize(counter)
          next_rank_points = (counter == 1 ? 0 : previous.score - l.score + 1)
          break
        else
          previous = l
          counter += 1
        end
      end
      return user_rank, next_rank_points 
    end
    
    def calculate_path_statistics(path, time)
      # User points
      user_points = {"0-50" => 0, "51-100" => 0, "101-500" => 0, "501-2000" => 0, "2000+" => 0 }
      path.enrollments.select(:total_points).each do |e|
        if e.total_points <= 50
          user_points["0-50"] += 1
        elsif e.total_points <= 100
          user_points["51-100"] += 1
        elsif e.total_points <= 500
          user_points["101-500"] += 1
        elsif e.total_points <= 2000
          user_points["501-2000"] += 1
        else
          user_points["2000+"] += 1
        end
      end
      
      # Completed tasks over time
      activity_over_time = []
      (0..@time).each do |d|
        completed_tasks = @path.completed_tasks.where("completed_tasks.updated_at <= ? and completed_tasks.updated_at > ?", d.days.ago, (d+1).days.ago).count
        enrollments = @path.enrollments.where("enrollments.created_at <= ? and enrollments.created_at > ?", d.days.ago, (d+1).days.ago).count
        activity_over_time << {:date => d.days.ago.strftime("%b %d"), :completed_tasks => completed_tasks, :enrollments => enrollments}
      end
      activity_over_time.reverse!
      
      # Path score
      path_score = ((@path.completed_tasks.average("status_id", :conditions => ["completed_tasks.updated_at > ?", @time.days.ago]) || 0) * 100).to_i
      
      return [user_points, activity_over_time, path_score]
    end
end