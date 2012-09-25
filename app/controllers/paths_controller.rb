class PathsController < ApplicationController
  include OrderHelper
  
  before_filter :authenticate, :except => [:show, :jumpstart]
  before_filter :admin_only, :only => [:index]
  before_filter :get_path_from_id, :except => [:index, :new, :create]
  before_filter :can_create?, :only => [:new, :create]
  before_filter :can_edit?, :only => [:edit, :update, :reorder_sections, :destroy, :collaborator, :collaborators]
  before_filter :can_view?, :only => [:show]
  before_filter :can_continue?, :only => [:continue]
  
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
    if @path.save
      flash[:success] = "#{name_for_paths} created."
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
    if @path.sections.where(["is_published = ?", true]).count.zero?
      flash[:error] = "You need to publish at least one section before you can make your challenge publicly available."
    elsif @path.default_pic?
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
  
  def continue
    @section = current_user.most_recent_section_for_path(@path)
    if @section.completed?(current_user)
      while @section.completed?(current_user)
        @section = @path.next_section(@section)
        break if @section.nil?
      end
    end
    
    unless @section.nil? || @section.is_published == false
      if @section.instructions.blank? && @section.stored_resources.empty?
        redirect_to continue_section_path(@section)
      else
        redirect_to @section
      end
    else
      previous_ranking = Leaderboard.reset_for_path_user(@path, current_user)
      unless @path.has_creative_response
        current_user.enrollments.find_by_path_id(@path.id).update_attribute(:is_complete, true)
        @path.create_completion_event(current_user, name_for_paths)
      end
      
      if @path.has_creative_response && !@path.enable_voting
        flash[:success] = "Congratulations! You've finished this #{name_for_paths}. You should recieve an email with your final score as soon as your administrator finishes grading your answers."
      else
        flash[:success] = "Congratulations! You've finished this #{name_for_paths}."
      end
      redirect_to @path
    end
  end
  
  def retake
    @enrollment = @path.enrollments.find_by_user_id(current_user.id)
    @enrollment.retake!
    @path.completed_tasks.where("user_id = ?", current_user.id).destroy_all
    Leaderboard.reset_for_path_user(@path, current_user)
    redirect_to @path
  end
  
  def community
    @enrollment = current_user.enrolled?(@path) || current_user.enrollments.create(path_id: @path.id)
    @total_points_earned = @enrollment.total_points
    @skill_ranking = @enrollment.skill_ranking
    
    @current_section = current_user.most_recent_section_for_path(@path)
    @unlocked = @current_section.unlocked?(current_user)
    
    Leaderboard.reset_for_path_user(@path, current_user) if params[:completed]
    @leaderboards = Leaderboard.get_leaderboards_for_path(@path, current_user, false).first[1]
    @next_rank_points, @user_rank = get_rank_and_next_points(@leaderboards) 
    
    @votes = current_user.votes.to_a.collect {|v| v.submitted_answer_id }
    @tasks = @path.tasks
    
    if params[:task]
      @responses = @path.completed_tasks.joins(:submitted_answer).where("completed_tasks.task_id = ?", params[:task]).order("total_votes DESC")
    elsif params[:order] && params[:order] == "date"
      @responses = @path.completed_tasks.joins(:submitted_answer).all(order: "completed_tasks.created_at DESC")
    else
      @responses = @path.completed_tasks.joins(:submitted_answer).all(order: "total_votes DESC")
    end
    @activity_stream = @path.activity_stream
    @display_dashboard = params[:completed]
  end
  
  def show
    redirect_to community_path_path(@path, completed: params[:completed]) if current_company.id == 1
    if signed_in?
      @enrolled = current_user.enrolled?(@path)
      @completed = @path.has_creative_response ? @path.total_remaining_tasks(current_user) == 0 : @path.completed?(current_user)
      @start_mode = "Continue #{name_for_paths}"
    else
      @user = User.create_anonymous_user(Company.find(1))
      sign_in(@user)
      current_user.enrollments.create!(:path_id => @path.id)
      @enrolled = true, @completed = false
      @start_mode = "Start #{name_for_paths}"
    end
  
    store_location #So user will be redirected here after registration
    @must_register = current_user.must_register?
    
    @leaderboards = Leaderboard.get_leaderboards_for_path(@path, current_user, false).first[1]
    if @completed
      @total_points_earned = @path.enrollments.find_by_user_id(current_user.id).total_points
      @skill_ranking = @enrolled.skill_ranking
      @next_rank_points, @user_rank = get_rank_and_next_points(@leaderboards)
    end
    
    @similar_paths = Path.similar_paths(@path, current_user)
       
    if @path.enable_voting && @path.has_creative_response
      @show_voting = true
      @votes = current_user.votes.to_a.collect {|v| v.submitted_answer_id }
      @order = params[:order] == "votes" ? "submitted_answers.total_votes DESC" : "submitted_answers.created_at DESC"
    else
      @votes = []
      @order = "submitted_answers.created_at DESC"
    end
   
    unless @must_register
      @task_ids = []
      @creative_tasks = []
      @knowledge_tasks = []
      if params[:task_id]
        @in_drill_down = true
        task = @path.tasks.find(params[:task_id])
        if task.answer_type == 0
          @creative_tasks << { :task => task, 
            :submitted_answers => task.submitted_answers.all(:order => @order), 
            :users_completed_task => task.completed_tasks.find_by_user_id(current_user.id), 
            :answers => task.answers }
          @task_ids << task.id
          @current_users_answers = current_user.submitted_answers.find_by_task_id(task.id)
          @current_users_answers = [@current_users_answers.id] unless @current_users_answers.nil?
        else
          @task_ids << task.id
          @knowledge_tasks << { :task => task,
            :users_completed_task => task.completed_tasks.find_by_user_id(current_user.id), 
            :answers => task.answers }
        end
      else
        @path.tasks.includes(:completed_tasks, :answers)
          .where("completed_tasks.user_id = ?", current_user.id)
          .all(:limit => 100, :order => "tasks.id ASC").each do |t|
          @task_ids << t.id
          users_completed_task = t.completed_tasks.first
          task = { :task => t, 
            :submitted_answers => t.submitted_answers.all(:order => @order, :limit => 10), 
            :users_completed_task => users_completed_task, 
            :answers => t.answers }
          
          t.answer_type == 0 ? (@creative_tasks << task) : (@knowledge_tasks << task)
        end
        @current_users_answers = current_user.submitted_answers.where("submitted_answers.task_id IN (?)", @task_ids).to_a.collect {|c| c.id }
      end
    end
    
    @activity_stream = @path.activity_stream
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
      if params[:user]
        @enrollment = @path.enrollments.find_by_user_id(params[:user])
        @user = @enrollment.user
      else
        @user = @path.enrolled_users.first
      end
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
    
    def can_view?
      unless 
      (@path.company_id == 1 && @path.is_published) ||
      (@path.is_published && @path.user_roles.find_by_id(current_user.user_role.id) && !@path.is_locked) ||
      (@path.user_id = current_user.id) ||
      (@path.company_id == current_user.company_id && @enable_collaboration)
        redirect_to root_path
      end
    end
    
    def can_continue?
      redirect_to root_path unless current_user.enrolled?(@path)
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