class PathsController < ApplicationController
  before_filter :authenticate, except: [:show]
  before_filter :get_path_from_id, :except => [:show, :index, :new, :create]
  before_filter :can_create?, :only => [:new, :create]
  before_filter :can_edit?, :only => [:edit, :update, :destroy, :collaborator, :collaborators]
  
# Begin Path Creation
  
  def new
    @path = Path.new
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
    if @path.sections.empty?
      redirect_to new_section_path(:path_id => @path.id) and return
    end
    @sections = @path.sections.includes({ :tasks => :answers }).all(order: "id ASC")
  end
  
  def update
    @path.name = params[:path][:name]
    @path.description = params[:path][:description]
    @path.save
    unless params[:stored_resource_id].blank?
      @path.stored_resource.destroy if @path.stored_resource
      sr = StoredResource.find(params[:stored_resource_id])
      raise "FATAL: STEALING RESOURCE" if sr.owner_id
      sr.owner_id = @path.id
      sr.owner_type = @path.class.to_s
      sr.save
    end
    redirect_to edit_path_path(@path)
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

  def collaborator
    if request.get?
      @collaborators = @path.collaborating_users
      @collaborator = @path.collaborations.new
    else
      if params[:collaborator].nil? || !(@user = User.find_by_email(params[:collaborator][:email]))
        flash[:error] = "MetaBright user does not exist."
      else 
        @collaboration = @path.collaborations.new(user_id: @user.id, granting_user_id: current_user.id)
        if @collaboration.save
          flash.now[:success] = "#{@user.name} successfully added as a collaborator."
        else
          flash.now[:error] = @collaborator.errors.full_messages.join(". ")
        end
      end
      redirect_to collaborator_path_path(@path)
    end
  end

  def undo_collaboration
    @collaboration = @path.collaborations.find_by_user_id(params[:user_id])
    if @collaboration.destroy
      flash[:alert] = "User will no longer have access."
    else
      flash[:error] = @collaboration.errors.full_messages.join(". ")
    end
    redirect_to collaborator_path_path(@path)
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
    @path = Path.find_by_permalink(params[:permalink]) if params[:permalink]
    @path = Path.find(params[:id]) if params[:id]
    
    redirect_to root_path and return unless @path.is_public == true
    @leaderboards = Leaderboard.includes(:user).where("path_id = ?", @path.id).all(order: "score DESC", limit: 10)
    @enrolled_users = @path.enrolled_users.limit(15).to_a.shuffle
    @tasks = @path.tasks
    @votes = []
    if current_user
      @enrollment = current_user.enrolled?(@path) || current_user.enrollments.create(path_id: @path.id)
      @current_section = current_user.most_recent_section_for_path(@path)
      @votes = current_user.votes.to_a.collect {|v| v.submitted_answer_id }
      @display_launchpad = params[:completed]
      @display_type = params[:type] || 2
    else
      @display_sign_in = true
      session[:referer] = @path.id 
    end
    
    @page = params[:page].to_i
    offset = @page * 30
    if params[:submission]
      @responses = @path.completed_tasks.joins(:submitted_answer, :task).where("submitted_answers.id = ?", params[:submission])
      @sharing = true
    elsif params[:task]
      @responses = @path.completed_tasks.joins(:submitted_answer, :task).offset(offset).limit(30).where("completed_tasks.task_id = ?", params[:task]).order("total_votes DESC")
    elsif params[:order] && params[:order] == "votes"
      @responses = @path.completed_tasks.joins(:submitted_answer, :task).offset(offset).limit(30).where("tasks.answer_type = ?", Task::CREATIVE).order("total_votes DESC")
    else
      @responses = @path.completed_tasks.joins(:submitted_answer, :task).offset(offset).limit(30).where("tasks.answer_type = ?", Task::CREATIVE).order("completed_tasks.created_at DESC")
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
        flash[:error] = "You do not have access to this Challenge. Please contact your administrator to gain access."
        redirect_to root_path
      end
    end
end