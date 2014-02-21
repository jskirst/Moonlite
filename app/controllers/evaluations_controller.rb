class EvaluationsController < ApplicationController
  include EnrollmentsHelper
  include GroupsHelper

  before_filter :authenticate, except: [:take]
  before_filter :load_group_and_evaluation
  before_filter :authorize_group, except: [:take, :continue, :challenge, :answer, :take_confirmation, :submit]
  before_filter { @show_footer = true and @hide_background = true }
  before_filter :prepare_form, only: [:new, :create, :edit, :update]
  before_filter :candidates_check

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
    @paths = @evaluation.paths
    @evaluations = @evaluation.evaluation_enrollments.where("submitted_at is not ?", nil)
      .joins(:user)
      .select("users.*, evaluation_enrollments.*")
    @archive_exists = @evaluation.evaluation_enrollments.where("submitted_at is not ?", nil)
      .where("evaluation_enrollments.archived_at is not ?", nil)
      .any?
    if params[:archived]
      @evaluations = @evaluations.where.not("evaluation_enrollments.archived_at is ?", nil)
    else
      @evaluations = @evaluations.where("evaluation_enrollments.archived_at is ?", nil)
    end
    if params[:archived]
      @showing_archived = true
    end
    if @group.plan_type == "free_to_demo"
      @is_trial = true
    end
    @paths.each do |p|
      e = "e#{p.id}"
      @evaluations = @evaluations.joins("LEFT JOIN enrollments #{e} on #{e}.user_id=evaluation_enrollments.user_id and #{e}.path_id=#{p.id}")
      @evaluations = @evaluations.select("#{e}.metapercentile as #{e}_total_points, #{e}.metapercentile as #{e}_metapercentile, #{e}.metascore as #{e}_metascore")
    end
  end
  
  def bulk_save
    action_mode = params[:action_mode]
    time = Time.now()
    params[:eval_enrollment_ids].each do |id|
      ee = @evaluation.evaluation_enrollments.where("evaluation_enrollments.id = ?", id).first
      if action_mode == "archive"
        ee.update_attribute(:archived_at, time)
      elsif action_mode == "unarchive"
        ee.update_attribute(:archived_at, nil)
      else
        raise "Access Denied: Unknown mode[#{params[:action_mode]}]"
      end
    end
    redirect_to group_evaluation_path(@group, @evaluation)
  end
  
  def new
    @evaluation = @group.evaluations.new(company: @group.name)
    @title = "Create a new Evaluation"
    if @group.plan_type == "free_to_demo"
      @is_trial = true
    end
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
  
  def review
    if @group.plan_type == "free_to_demo"
      @is_trial = true
    end
  end
  
  def grade
    @evaluation_enrollment = @evaluation.evaluation_enrollments.find_by_user_id(params[:u])
    @user = @evaluation_enrollment.user
    @results = []
    @evaluation.paths.each do |path|
      enrollment = @user.enrollments.find_by_path_id(path.id)
      next unless enrollment
      @results << extract_enrollment_details(enrollment)
    end
  end

  def export
    @evaluation_enrollment = @evaluation.evaluation_enrollments.find_by_user_id(params[:u])
    pdf = EvaluationExport.new(@evaluation_enrollment, view_context)
    send_data pdf.render, 
      filename: "evaluation_#{@evaluation_enrollment.id}.pdf",
      type: "application/pdf",
      disposition: "inline"
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
    unless @evaluation
      clear_return_back_to
      redirect_to root_url and return
    end
    
    if current_user
      current_user.update_attribute(:private_at, Time.now)
      @evaluation_enrollment = @evaluation.evaluation_enrollments.find_by_user_id(current_user.id)
      if @evaluation_enrollment.nil?
        @evaluation_enrollment = @evaluation.evaluation_enrollments.create!(user_id: current_user.id, evaluation_id: @evaluation.id)
      end
    end
    @group = @evaluation.group
    if current_user
      cookies.delete :evaluation
    else
      cookies[:evaluation] = @evaluation.permalink
    end
  end
  
  def continue
    @show_nav_bar = false
    @show_footer = false
    @show_feedback = false
    @path = @evaluation.paths.find(params[:path_id])
    unless @enrollment = current_user.enrolled?(@path)
      @enrollment = current_user.enroll!(@path)
    end
    unless @evaluation_enrollment = current_user.enrolled?(@evaluation)
      current_user.enroll!(@evaluation)
    end
    
    next_task = @evaluation.next_task(current_user, @path)
    if next_task
      @task = next_task[:next_task] 
    end

    if @task
      @session_id = params[:session_id] || Time.now().to_i + current_user.id
      @streak = session[:ssf].to_i
      if @streak > @enrollment.longest_streak
        @enrollment.update_attribute(:longest_streak, @streak)
      end
      
      @completed_task = CompletedTask.find_or_create(current_user, @task, @enrollment, @session_id)

      @answers = Answer.cached_find_by_task_id(@task.id).shuffle
      @stored_resource = @task.stored_resources.first
      if @task.core?
        @question_count = next_task[:completed_count]+1
        @session_total = next_task[:total]
        
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
        @question_count = next_task[:completed_count]+1
        @session_total = next_task[:total]
        @submitted_answer = @completed_task.submitted_answer_id ? @completed_task.submitted_answer : SubmittedAnswer.new
        render "challenge"
      end
    else
      redirect_to take_group_evaluation_path(@evaluation.permalink)
    end
  end
  
  def submit
    @show_nav_bar = false
    @show_footer = false
    @evaluation_enrollment = current_user.evaluation_enrollments.find_by_evaluation_id(params[:id])
    unless @evaluation_enrollment.submitted?
      @group.admins.each do |admin|
        UserEvent.log_event(admin, "#{current_user.name} has just submitted their Evaluation for the #{@evaluation.title} position.", current_user, grade_group_evaluation_url(@group, @evaluation, u: current_user.id), current_user.picture)  
        GroupMailer.submission(@evaluation_enrollment).deliver
      end
      @evaluation_enrollment.update_attribute(:submitted_at, Time.now)
    end
    
    @evaluation_enrollment.evaluation.paths.each do |path|
      enrollment = current_user.enrolled?(path)
      enrollment.calculate_metascore
      enrollment.calculate_metapercentile
    end
    @paths = Path.by_popularity(8).where("promoted_at is not ?", nil).to_a
  end
  
  def destroy
    @evaluation.destroy
    flash[:success] = "Evaluation has been deleted."
    redirect_to group_evaluations_url(@group)
  end
  
  private
  
  def load_group_and_evaluation
    @evaluation = Evaluation.find(params[:id]) if params[:id]
    @evaluation = Evaluation.find(params[:evaluation_id]) if params[:evaluation_id]
    @evaluation = Evaluation.find_by_permalink(params[:permalink]) if params[:permalink]
    @group = Group.find_by_permalink(params[:group_id]) if params[:group_id]
    @group = Group.find(params[:group_id]) if not @group and params[:group_id]
    
    if @evaluation and @group
      raise "Access Denied: Not your evaluation" unless @evaluation.group_id == @group.id
    elsif @evaluation and not @group
      @group = @evaluation.group
    end
    
    if @group
      @group_custom_style = @group.custom_style
    end
  end
  
  def authorize_group
    unless @group.admin?(current_user)
      raise "Access Denied"
    end
  end
  
  def prepare_form
    @group_path_collection = []
    @group.paths.each do |path|
      if path.tasks.count > 0
        @group_path_collection << path
      end
    end
    @evaluation_path_ids = @evaluation ? @evaluation.paths.pluck(:id) : []
    if params[:c].present?
      @evaluation_path_ids << params[:c].to_i
    end
    @public_paths = Path.where.not(professional_at: nil)
    @public_paths = @public_paths.sort_by{|path| [path.name.upcase]}
    @public_paths = @public_paths.sort do |a,b| 
      if @evaluation_path_ids.include?(b.id) == @evaluation_path_ids.include?(a.id)
        a.name.upcase <=> b.name.upcase
      else
        (@evaluation_path_ids.include?(b.id) ? 1 : -1) <=> (@evaluation_path_ids.include?(a.id) ? 1 : -1)
      end
    end
  end
end