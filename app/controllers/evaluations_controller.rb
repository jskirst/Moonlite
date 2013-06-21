class EvaluationsController < ApplicationController
  before_filter :authenticate, except: [:take]
  before_filter :load_group, except: [:take, :continue, :challenge, :answer]
  before_filter :authorize_group, except: [:take, :continue, :challenge, :answer, :take_confirmation]
  before_filter { @show_footer = true and @hide_background = true }

  def index
    @evaluations = @group.evaluations.all
    @open_evaluations = @evaluations.select{ |e| e.closed_at.nil? }
    @closed_evaluations = @evaluations.select{ |e| e.closed_at }
  end
  
  def show
    @evaluation = @group.evaluations.find(params[:id])
    @paths = @evaluation.paths
    @evaluations = @evaluation.evaluation_users.joins(:user).select("evaluation_users.*, users.*")
    @paths.each do |p|
      e = "e#{p.id}"
      @evaluations = @evaluations.joins("LEFT JOIN enrollments #{e} on #{e}.user_id=evaluation_users.user_id and #{e}.path_id=#{p.id}")
      @evaluations = @evaluations.select("#{e}.metapercentile as #{e}_metapercentile, #{e}.metascore as #{e}_metascore")
    end
  end
  
  def new
    @evaluation = @group.evaluations.new
    @paths = Persona.first.paths
    @title = "Create a new Evaluation"
  end
  
  def create
    @evaluation = @group.evaluations.new(params[:evaluation])
    @evaluation.user_id = current_user.id
    if @evaluation.save
      redirect_to create_confirmation_group_evaluation_path(@group, @evaluation)
    else
      @paths = Persona.first.paths
      @title = "Create a new Evaluation"
      render "new"
    end
  end
  
  def create_confirmation
    @evaluation = current_user.authored_evaluations.find(params[:id])
  end
  
  def take
    @evaluation = Evaluation.find_by_permalink(params[:permalink])
    @group = @evaluation.group
    unless current_user
      cookies[:evaluation] = @evaluation.permalink
    end
  end
  
  def continue
    @evaluation = Evaluation.find(params[:evaluation_id])
    @path = @evaluation.paths.find_by_id(params[:path_id])
    unless @enrollment = current_user.enrolled?(@path)
      @enrollment = current_user.enroll!(@path)
    end
    
    @task = @evaluation.next_core_task(current_user, @path)
    
    if @task
      @session_id = params[:session_id] || Time.now().to_i + current_user.id
      @streak = session[:ssf].to_i
      if @streak > @enrollment.longest_streak
        @enrollment.update_attribute(:longest_streak, @streak)
      end
      @completed_task = current_user.completed_tasks.create!(task_id: @task.id, enrollment_id: @enrollment.id, session_id: @session_id)
      @answers = Answer.cached_find_by_task_id(@task.id).shuffle
      @stored_resource = @task.stored_resources.first
      
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
      redirect_to challenge_evaluation_path(@evaluation, @path)
    end
  end
  
  def challenge
    @evaluation = Evaluation.find(params[:evaluation_id])
    @path = @evaluation.paths.find_by_id(params[:path_id])
    unless @enrollment = current_user.enrolled?(@path)
      @enrollment = current_user.enroll!(@path)
    end
    @task = @evaluation.next_challenge_task(current_user, @path)    
  end

  def take_confirmation
    @evaluation = current_user.evaluations.find(params[:id])
    @paths = Path.by_popularity(8).where("promoted_at is not ?", nil).to_a
  end
  
  private
  
  def load_group
    @group = Group.find(params[:group_id])
  end
  
  def authorize_group
    @group_user = @group.group_users.find_by_user_id(current_user.id)
    raise "Access Denied: Not Group Admin" unless @group_user.is_admin?
  end
end