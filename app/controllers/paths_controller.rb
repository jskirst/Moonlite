class PathsController < ApplicationController
  include OrderHelper
  
  before_filter :authenticate, :except => [:hero, :show, :jumpstart]
  before_filter :admin_only, :only => [:index, :change_company]
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
  
  #GET
  def collaborators
    @collaborators = @path.collaborating_users
    @collaborator = @path.collaborations.new
  end
  
  #PUT
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
      render "collaborators"
      return
    end
    redirect_to collaborators_path_path(@path)
  end
  
  #GET
  def undo_collaboration
    if @collaboration = @path.collaborations.find_by_user_id(params[:user_id])
      if @collaboration.destroy
        flash[:sad_success] = "User will no longer have access."
      else
        flash[:error] = @collaboration.errors.full_messages.join(". ")
      end
    else
      flash[:error] = "No such user."
    end
    redirect_to collaborators_path_path(@path)
  end

# Begin Path Journey
 
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
      current_user.enrollments.find_by_path_id(@path.id).update_attribute(:is_complete, true)
      award_achievements
      redirect_to @path
    end
  end
  
  def show
    unless signed_in?
      @user = User.create_anonymous_user(Company.find(1))
      sign_in(@user)
      current_user.enrollments.create!(:path_id => @path.id)
      @enrolled = true, @completed = false
      @start_mode = "Start #{name_for_paths}"
    else
      @enrolled = current_user.enrolled?(@path)
      @completed = @path.completed?(current_user)
      @start_mode = "Continue #{name_for_paths}"
    end
  
    store_location #So user will be redirected here after registration
    @must_register = current_user.must_register?
    
    @leaderboards = Leaderboard.get_leaderboards_for_path(@path, current_user, false).first[1]
    if @completed
      @total_points_earned = @path.enrollments.find_by_user_id(current_user.id).total_points
      # This can be optimized by grabbing the top 10 + yours and then the count between. 3 queries
      @skill_ranking = @path.skill_ranking(current_user)
    
      counter = 1
      previous = nil
      @leaderboards.each do |l|
        if l.user_id == current_user.id
          @next_rank_points = (counter == 1 ? 0 : previous.score - l.score + 1)
          @user_rank = ActiveSupport::Inflector::ordinalize(counter)
          break
        else
          previous = l
          counter += 1
        end
      end
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
        @creative_tasks << { :task => task, 
          :submitted_answers => task.submitted_answers.all(:order => @order), 
          :users_completed_task => task.completed_tasks.find_by_user_id(current_user.id), 
          :answers => task.answers }
        @task_ids << task.id
        @current_users_answers = current_user.submitted_answers.find_by_task_id(task.id)
        @current_users_answers = [@current_users_answers.id] unless @current_users_answers.nil?
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
  end
  
# Administration #
  def index
    if params[:search]
      @paths = Path.paginate(:page => params[:page], 
        :conditions => ["name ILIKE ? or description ILIKE ? or tags ILIKE ?", 
          "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%"], :order => "id DESC")
    else
      @paths = Path.paginate(:page => params[:page], :order => "id DESC")
    end
  end
  
  def change_company
    if params[:company_id]
      company = Company.find(params[:company_id])
      if company
        @path.company_id = company.id
        if @path.save
          @path.path_user_roles.destroy_all
          @path.enrollments.destroy_all
          @path.category_id = nil
          @path.save
          flash[:success] = "Company #{name_for_paths} transfer succcessful."
        else
          flash[:error] = "Company #{name_for_paths} transfer unsucccessful. Please try again."
        end
      else
        flash[:error] = "Company could not be found. Please try again."
      end
    end
    @companies = Company.all
  end
  
  def dashboard
    @page = params[:page] || 1
    @time = (params[:time] || 7).to_i
    @user_points, @activity_over_time, @path_score = calculate_path_statistics(@path, @time)
    @unresolved_tasks = @path.completed_tasks.includes(:submitted_answer).where("status_id = ?", 2).paginate(:page => params[:page], :per_page => 20)
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
    
    def award_achievements
      incomplete_achievements = []
      completed_achievements = []
      completed_paths = current_user.enrollments.where("is_complete = ?", true).to_a.collect {|e| e.path_id}
      current_user.company.achievements.includes(:path_achievements).each do |a|
        criteria = a.path_achievements.all.to_a.collect {|pa| pa.path_id }
        completed_criteria = 0
        criteria.each {|c| completed_criteria += 1 if completed_paths.include?(c)}
        if completed_criteria == criteria.size
          unless current_user.achievements.find_by_id(a.id)
            current_user.user_achievements.create!(:achievement_id => a.id)
            flash[:success] = "You unlocked the #{a.name} Achievement!"
          end
        elsif (criteria - completed_paths) != criteria
          flash[:success] = [flash[:success].to_s, "You almost unlocked the #{a.name} Achievement!"].join(" ")
        end
      end
    end
end