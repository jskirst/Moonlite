class PathsController < ApplicationController
  include PathsHelper
  include NewsfeedHelper
  
  before_filter :authenticate, except: [:show, :newsfeed, :drilldown, :marketing]
  before_filter :load_resource, except: [:index, :new, :create, :drilldown, :marketing, :start]
  before_filter :authorize_edit, only: [:edit, :update, :destroy, :collaborator, :collaborators]
  before_filter :authorize_view, only: [:continue, :show, :newsfeed]
  
# Begin Path Creation
  
  def new
    @path = Path.new
    @exact_path = nil
    @similar_paths = []
  end
  
  def start
    @path = Path.new
    name = params[:path][:name]
    @exact_path = Path.find_by_name(name)    
    unless params[:skip]
      @similar_paths = Path.where("name ILIKE ?", "%#{name}%")
    end
    if @exact_path or not @similar_paths.empty?
      render "new"
    else
      @path.name = name
      render "start"
    end
  end
    

  def create
    @path = current_user.company.paths.new(params[:path])
    @path.user_id = current_user.id
    @path.approved_at = nil
    @path.published_at = nil
    if @path.save
      if params[:stored_resource_id]
        assign_resource(@path, params[:stored_resource_id])
      end
      
      if @path.template_type == "blank"
        @path.sections.create!(name: "First Section")
      elsif @path.template_type == "subtopic"
        @path.sections.create!(name: "Topic 1")
        @path.sections.create!(name: "Topic 2")
        @path.sections.create!(name: "Topic 3")
        @path.sections.create!(name: "Topic 4")
      elsif @path.template_type == "difficulty"
        @path.sections.create!(name: "Novice")
        @path.sections.create!(name: "Intermediate")
        @path.sections.create!(name: "Advanced")
        @path.sections.create!(name: "Expert")
      else
        raise "Fatal: Unknown template type"
      end
      
      redirect_to edit_path_path(@path.permalink)
    else
      @categories = current_user.company.categories
      render 'new'
    end
  end
  
  def join
    if current_user.earned_points > 800
      @path.collaborations.create!(user_id: current_user.id, granting_user_id: @path.user_id)
      redirect_to edit_path_path(@path)
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
    @path.name = params[:path][:name] if params[:path][:name]
    @path.description = params[:path][:description] if params[:path][:name]
    
    if @enable_administration
      unless params[:path][:persona].blank?
        @path.path_personas.destroy_all
        @path.path_personas.create!(persona_id: params[:path][:persona])
      end
      @path.promoted_at = params[:path][:promoted].to_i == 1 ? Time.now : nil
      @path.approved_at = params[:path][:approved].to_i == 1 ? Time.now : nil
    end
    
    @path.save
    
    unless params[:stored_resource_id].blank?
      @path.stored_resource.destroy if @path.stored_resource
      sr = StoredResource.find(params[:stored_resource_id])
      raise "FATAL: STEALING RESOURCE" if sr.owner_id
      sr.owner_id = @path.id
      sr.owner_type = @path.class.to_s
      sr.save
    end
    
    if @enable_administration
      redirect_to admin_paths_path
    else
      redirect_to edit_path_path(@path.permalink)
    end
  end
  
  def publish
    if @path.default_pic?
      flash[:info] = "You need to set a custom picture for your #{name_for_paths} before you can publish it. You can do that by clicking the Settings button."
    elsif @path.description.blank?
      flash[:info] = "You need to create a description for your #{name_for_paths} before you can publish it. You can do that by clicking the Settings button."
    else
      now = Time.now
      @path.sections.each { |s| s.update_attribute(:published_at, now) }
      @path.published_at = now
      @path.public_at = now
      if @path.save
        flash[:success] = "#{@path.name} has been submitted. Once approved by an administrator, it will be accessible by the MetaBright community."
      else
        flash[:error] = "There was an error publishing."
      end
    end
    redirect_to edit_path_path(@path.permalink)
  end
  
  def unpublish
    @path.published_at = nil
    if @path.save
      flash[:success] = "#{name_for_paths} has been unpublished and is no longer visible."
    else
      flash[:error] = "Oops, could not unpublish this #{name_for_paths}. Please try again."
    end
    redirect_to edit_path_path(@path.permalink)
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
    section = @path.next_section_for_user(current_user)
    
    if section.nil? || section.published_at.nil?
      redirect_to challenge_path(@path.permalink)
    else
      redirect_to start_section_path(section)
    end
  end
  
  def show
    if @path.public_at.nil? && (current_user.nil? || @path.user != current_user)
      redirect_to root_path and return
    end
    
    @title = "#{@path.name} Quiz" 
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
        .where("tasks.section_id = ? and tasks.locked_at is ? and tasks.reviewed_at is not ?", @current_section.id, nil, nil)

      @core_tasks = @tasks.select { |t| t.core? }
      @challenge_tasks = @tasks.select { |t| t.creative? }
      @achievement_tasks = @tasks.select { |t| t.task? }
      
      @completed = params[:c]
      @points_gained = params[:p]
      if @completed && @points_gained
        @achievements = check_achievements(@points_gained.to_i, @enrollment)
      else
        @achievements = {}
      end
    else
      @display_sign_in = true
      session[:referer] = @path.id 
    end
    
    @similar_paths = @path.similar_paths
    social_tags(@path.name, @path.picture, @path.description)
    @display_launchpad = @completed
    @display_type = params[:type] || 2
    
    @enrollments = @path.enrollments.includes(:user)
      .where("users.locked_at is ? and total_points > ?", nil, 0)
      .order("total_points DESC").limit(10)
      .eager_load.to_a
    @leaderboard = User.joins(:enrollments)
      .select("users.id, enrollments.path_id, enrollments.total_points, users.name, users.username, users.locked_at, users.image_url")
      .where("enrollments.path_id = ? and users.locked_at is ? and total_points > ?", @path.id, nil, 0)
      .order("enrollments.total_points DESC")
      .limit(1000)
    
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
    feed = Feed.new(params, current_user)
    feed.url = newsfeed_path_path(@path.id, order: params[:order])
    feed.votes = current_user.vote_list if current_user
    feed.page = params[:page].to_i
    offset = feed.page * 15
    feed.posts = CompletedTask.joins(:submitted_answer, :user, :task => { :section => :path })
      .select(newsfeed_fields)
      .where("completed_tasks.status_id = ?", Answer::CORRECT)
      .where("submitted_answers.locked_at is ?", nil)
      .where("submitted_answers.reviewed_at is not ?", nil)
      .where("path_id = ?", @path.id)
    if params[:submission]
      feed.posts = feed.posts.where("submitted_answers.id = ?", params[:submission])
    else
      if params[:task]
        feed.posts = feed.posts.where("completed_tasks.task_id = ?", params[:task]).order("total_votes DESC")
      elsif params[:order] == "newest"
        feed.posts = feed.posts.order("completed_tasks.created_at DESC")
      elsif params[:order] == "top"
        feed.posts = feed.posts.order("total_votes DESC")
      else
        feed.posts = feed.posts.order("hotness DESC")
      end
    end
    feed.posts = feed.posts.offset(offset).limit(15)
    
    render partial: "newsfeed/feed", locals: { feed: feed }
  end
  
  def marketing
    path_name = request.url.split("/").last
    if path = Path.find_by_permalink(path_name)
      redirect_to challenge_path(path_name)
    else
      redirect_to root_path
    end
  end

  private
    def load_resource
      @path = Path.find_by_permalink(params[:permalink]) if params[:permalink]
      @path = Path.find_by_permalink(params[:id]) if params[:id] && @path.nil?
      @path = Path.find_by_id(params[:id]) if params[:id] && @path.nil?
      redirect_to root_path unless @path
    end
    
    def authorize_edit
      raise "Edit Access Denied" unless @path.nil? || can_edit_path(@path) || @enable_administration
    end
    
    def authorize_view
      raise "View Access Denied" unless (@path.published_at && @path.approved_at && @path.published_at) || can_edit_path(@path)
    end
    
    def generate_newsfeed_url
      if params[:submission]
        return newsfeed_path_path(@path.permalink, submission: params[:submission])
      elsif params[:task]
        return newsfeed_path_path(@path.permalink, task: params[:task], page: params[:page])
      elsif params[:order]
        return newsfeed_path_path(@path.permalink, order: params[:order], page: params[:page])
      else
        return newsfeed_path_path(@path.permalink)
      end
    end
end