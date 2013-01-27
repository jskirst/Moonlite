class PathsController < ApplicationController
  before_filter :authenticate, except: [:show, :newsfeed, :drilldown]
  before_filter :load_resource, except: [:index, :new, :create, :drilldown]
  before_filter :authorize_edit, only: [:edit, :update, :destroy, :collaborator, :collaborators]
  before_filter :authorize_view, only: [:continue, :show, :newsfeed]
  
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
      @path.is_published = true
      @path.is_public = true
      if @path.save
        flash[:success] = "#{@path.name} has been successfully published. It is now visible to the MetaBright community."
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
  
  def continue
    current_user.enroll!(@path) unless current_user.enrolled?(@path)
    @section = current_user.most_recent_section_for_path(@path) || @path.sections.first
    while @section && @section.completed?(current_user)
      @section = @path.next_section(@section)
    end
    
    if @section.nil? || @section.is_published == false
      redirect_to @path
    else
      redirect_to start_section_path(@section)
    end
  end
  
  def show
    @tasks = @path.tasks
    @responses = []
    if current_user
      @enrollment = current_user.enrolled?(@path) || current_user.enrollments.create(path_id: @path.id)
      if current_user.enrollments.size == 1 and @enrollment.total_points == 0
        redirect_to continue_path_path(@path) and return
      end
      @current_section = current_user.most_recent_section_for_path(@path)
      @tasks = Task.joins("LEFT OUTER JOIN completed_tasks on tasks.id = completed_tasks.task_id and completed_tasks.user_id = #{current_user.id}")
        .select("section_id, status_id, question, tasks.id, points_awarded, answer_type, answer_sub_type")
        .where("tasks.section_id = ? and tasks.is_locked = ?", @current_section.id, false)
      @core_tasks = @tasks.select { |t| t.answer_type == Task::MULTIPLE }
      @challenge_tasks = @tasks.select { |t| t.answer_type == Task::CREATIVE }
      @achievement_tasks = @tasks.select { |t| t.answer_type == Task::CHECKIN }
    else
      @display_sign_in = true
      session[:referer] = @path.id 
    end
    
    @social_title = @path.name
    @social_description = @path.description
    @social_image = @path.path_pic
    @display_launchpad = params[:completed]
    @display_type = params[:type] || 2
    
    @enrollments = @path.enrollments.includes(:user).order("total_points DESC").limit(10).eager_load.to_a
    
    @url_for_newsfeed = generate_newsfeed_url
    render "show"
  end
  
  def drilldown
    if params[:submission_id]
      submission = SubmittedAnswer.find(params[:submission_id])
      redirect_to submission_details_path(submission.path.permalink, submission.id)
    else
      task = Task.find(params[:task_id])
      redirect_to task_details_path(task.path.permalink, task.id)
    end
  end
  
  def newsfeed
    @votes = current_user.nil? ? [] : current_user.votes.to_a.collect {|v| v.submitted_answer_id } 
    @page = params[:page].to_i
    offset = @page * 20
    if params[:submission]
      @completed_tasks = @path.completed_tasks.joins(:submitted_answer, :task).where("submitted_answers.id = ?", params[:submission])
      @compact_social = false
    else
      @compact_social = true
      if params[:task]
        @completed_tasks = @path.completed_tasks.joins(:submitted_answer, :task).offset(offset).limit(20).where("completed_tasks.task_id = ?", params[:task]).order("total_votes DESC")
      elsif params[:order] && params[:order] == "votes"
        @completed_tasks = @path.completed_tasks.joins(:submitted_answer, :task).offset(offset).limit(20).where("tasks.answer_type = ?", Task::CREATIVE).order("total_votes DESC")
      else
        @completed_tasks = @path.completed_tasks.joins(:submitted_answer, :task).offset(offset).limit(20).where("tasks.answer_type = ?", Task::CREATIVE).order("completed_tasks.created_at DESC")
      end
    end
    @more_available_url = @completed_tasks.size == 20 ? newsfeed_path_path(@path.id, page: @page+1) : false
    render partial: "shared/newsfeed"
  end

  private
    def load_resource
      @path = Path.find_by_permalink(params[:permalink]) if params[:permalink]
      @path = Path.find_by_id(params[:id]) if params[:id]
      redirect_to root_path unless @path
    end
    
    def authorize_edit
      raise "Creation Access Denied" unless @enable_content_creation
      raise "Edit Access Denied" unless @path.nil? || can_edit_path(@path)
    end
    
    def authorize_view
      raise "View Access Denied" unless @path.is_public || can_edit_path(@path)
    end
    
    def generate_newsfeed_url
      if params[:submission]
        return newsfeed_path_path(@path, submission: params[:submission])
      elsif params[:task]
        return newsfeed_path_path(@path, task: params[:task], page: params[:page])
      elsif params[:order] && params[:order] == "votes"
        return newsfeed_path_path(@path, order: params[:order], page: params[:page])
      else
        return newsfeed_path_path(@path)
      end
    end
end