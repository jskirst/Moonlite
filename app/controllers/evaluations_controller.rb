class EvaluationsController < ApplicationController
  before_filter :authenticate, except: [:take]
  before_filter :load_group, except: [:take, :continue, :challenge, :answer]
  before_filter :load_evaluation, only: [:edit, :update, :review, :grade, :save]
  before_filter :authorize_group, except: [:take, :continue, :challenge, :answer, :take_confirmation]
  before_filter { @show_footer = true and @hide_background = true }
  before_filter :prepare_form, only: [:new, :create, :edit, :update]

  def index
    @evaluations = @group.evaluations
    if params[:q]
      @evaluations = @evaluations.where("company ILIKE ? or title ILIKE ?", "%#{params[:q]}%", "%#{params[:q]}%") unless params[:q].blank?
      if request.xhr?
        render partial: "evaluations/table"
        return
      end
    end
  end
  
  def show
    @evaluation = @group.evaluations.find(params[:id])
    @paths = @evaluation.paths
    @evaluations = @evaluation.evaluation_enrollments.where("submitted_at is not ?", nil)
      .joins(:user)
      .select("evaluation_enrollments.*, users.*")
    @archive_exists = @evaluation.evaluation_enrollments.where("submitted_at is not ?", nil)
      .where("evaluation_enrollments.archived_at is not ?", nil)
      .any?
    unless params[:archived]
      @evaluations = @evaluations.where("evaluation_enrollments.archived_at is ?", nil)
    end
    if params[:archived]
      @showing_archived = true
    end
    @paths.each do |p|
      e = "e#{p.id}"
      @evaluations = @evaluations.joins("LEFT JOIN enrollments #{e} on #{e}.user_id=evaluation_enrollments.user_id and #{e}.path_id=#{p.id}")
      @evaluations = @evaluations.select("#{e}.metapercentile as #{e}_total_points, #{e}.metapercentile as #{e}_metapercentile, #{e}.metascore as #{e}_metascore")
    end
  end
  
  def new
    @evaluation = @group.evaluations.new(company: @group.name)
    @title = "Create a new Evaluation"
  end
  
  def create
    @evaluation = @group.evaluations.new(params[:evaluation])
    @evaluation.user_id = current_user.id
    if @evaluation.save
      redirect_to review_group_evaluation_path(@group, @evaluation)
    else
      @title = "Create a new Evaluation"
      render "new"
    end
  end
  
  def edit
  end
  
  def update
    @evaluation.company = params[:evaluation][:company]
    @evaluation.title = params[:evaluation][:title]
    @evaluation.link = params[:evaluation][:link]
    @evaluation.selected_paths = params[:evaluation][:selected_paths]
    if @evaluation.save
      flash[:success] = "Evaluation successfully updated."
      redirect_to group_evaluations_path(@group)
    else
      render "edit"
    end
  end
  
  def review
  end
  
  def grade
    @evaluation_enrollment = @evaluation.evaluation_enrollments.find_by_user_id(params[:u])
    @user = @evaluation_enrollment.user
    @results = []
    @evaluation.paths.each do |path|
      @enrollment = @user.enrollments.find_by_path_id(path.id)
      core = @enrollment.completed_tasks.joins(:task => :topic)
        .select("topics.*, tasks.*, completed_tasks.*")
        .where("tasks.path_id = ?", path.id)
        .where("tasks.answer_type in (?)", [Task::MULTIPLE, Task::EXACT]).to_a
      creative = @enrollment.completed_tasks.joins(:task)
        .where("tasks.path_id = ?", path.id)
        .where("tasks.answer_type in (?)", [Task::CREATIVE]).to_a
      tasks = @enrollment.completed_tasks.joins(:task)
        .where("tasks.path_id = ?", path.id)
        .where("tasks.answer_type in (?)", [Task::CHECKIN]).to_a
      
      @results << { 
        name: path.name, 
        permalink: path.permalink, 
        core: core,
        creative: creative,
        tasks: tasks,
        performance: PerformanceStatistics.new(core),
        metascore: @enrollment.metascore,
        metapercentile: @enrollment.metapercentile
      }
    end
  end
  
  def save
    mode = params[:mode]
    time = Time.now()
    ee = @evaluation.evaluation_enrollments.find_by_user_id(params[:user_id])
    if mode == "favorite"
      ee.update_attribute(:favorited_at, time)
    elsif mode == "unfavorite"
      ee.update_attribute(:favorited_at, nil)
    elsif mode == "archive"
      ee.update_attribute(:archived_at, time)
    elsif mode == "unarchive"
      ee.update_attribute(:archived_at, nil)
    else
      raise "Access Denied: Unknown mode[#{params[:mode]}]"
    end
    redirect_to grade_group_evaluation_url(@group, @evaluation, u: params[:user_id])
  end
  
  def take
    @show_nav_bar = false
    @show_sign_in = false
    @evaluation = Evaluation.find_by_permalink(params[:permalink])
    if current_user
      @evaluation_enrollment = @evaluation.evaluation_enrollments.find_by_user_id(current_user.id)
      if @evaluation_enrollment.nil?
        @evaluation.evaluation_enrollments.create!(user_id: current_user.id, evaluation_id: @evaluation.id)
      end
    end
    @group = @evaluation.group
    unless current_user
      cookies[:evaluation] = @evaluation.permalink
    end
  end
  
  def continue
    @show_nav_bar = false
    @evaluation = Evaluation.find(params[:evaluation_id])
    @path = @evaluation.paths.find(params[:path_id])
    unless @enrollment = current_user.enrolled?(@path)
      @enrollment = current_user.enroll!(@path)
    end
    unless @evaluation_enrollment = current_user.enrolled?(@evaluation)
      current_user.enroll!(@evaluation)
    end
    
    unless params[:task_id] and @task = @path.tasks.find(params[:task_id])
      @task = @evaluation.next_task(current_user, @path)
    end

    if @task
      @session_id = params[:session_id] || Time.now().to_i + current_user.id
      @streak = session[:ssf].to_i
      if @streak > @enrollment.longest_streak
        @enrollment.update_attribute(:longest_streak, @streak)
      end
      @completed_task = CompletedTask.find_or_create(current_user.id, @task.id, session_id: @session_id)
      @answers = Answer.cached_find_by_task_id(@task.id).shuffle
      @stored_resource = @task.stored_resources.first
      if @task.core?
        session[:ssf] = @streak
        @start_countdown = true
        @show_stats = true
        @next_link = continue_evaluation_path(@evaluation, @path)
        if request.xhr?
          render file: "tasks/continue", layout: false
        else
          @hide_background = true
          render "tasks/continue"
        end
      else
        @submitted_answer = @completed_task.submitted_answer_id ? @completed_task.submitted_answer : SubmittedAnswer.new
        render "challenge"
      end
    else
      redirect_to take_group_evaluation_path(@evaluation.permalink)
    end
  end
  
  def submit
    @evaluation_enrollment = current_user.evaluation_enrollments.find_by_evaluation_id(params[:id])
    @evaluation_enrollment.update_attribute(:submitted_at, Time.now)
    @evaluation = @evaluation_enrollment.evaluation
    @paths = Path.by_popularity(8).where("promoted_at is not ?", nil).to_a
  end
  
  private
  
  def load_group
    @group = Group.find(params[:group_id])
  end
  
  def authorize_group
    unless @group.admin?(current_user) || @enable_administration
      raise "Access Denied"
    end
  end
  
  def load_evaluation
    @evaluation = @group.evaluations.find(params[:id])
  end
  
  def prepare_form
    @group_paths = @group.paths
    @public_paths = Persona.first.paths
    @evaluation_path_ids = @evaluation ? @evaluation.paths.pluck(:id) : []
  end
end