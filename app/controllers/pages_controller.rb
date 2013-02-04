class PagesController < ApplicationController
  before_filter :authenticate, except: [:home, :profile, :about, :challenges, :tos, :mark_help_read]
  before_filter :authorize_resource, only: [:create]
  
  def home
    @title = "Home"
    if signed_in?
      redirect_to start and return if params[:go] == "start"
      @enrollments = current_user.enrollments.includes(:path).where("paths.approved_at is not ?", nil).sort { |a,b| b.total_points <=> a.total_points }
      @enrolled_personas = current_user.personas
      @suggested_paths = Path.suggested_paths(current_user)
    else
      @show_sign_in = false
      render "landing", layout: "landing"
    end
  end
  
  def newsfeed
    @votes = current_user.votes.to_a.collect {|v| v.submitted_answer_id } 
    @completed_tasks = []
    @page = params[:page].to_i
    relevant_paths = current_user.enrollments.to_a.collect &:path_id
    if relevant_paths.empty?
      @completed_tasks = CompletedTask.joins(:task, :submitted_answer)
        .where("tasks.answer_type = ?", Task::CREATIVE)
        .order("completed_tasks.created_at DESC")
        .limit(30)
        .offset(@page * 30)
    else
      @completed_tasks = CompletedTask.joins({:task => :section}, :submitted_answer)
        .where("sections.path_id in (?) and tasks.answer_type = ?", relevant_paths, Task::CREATIVE)
        .order("completed_tasks.created_at DESC")
        .limit(30)
        .offset(@page * 30)
    end
    @compact_social = true
    @more_available_url = @completed_tasks.size == 30 ? newsfeed_path(page: @page+1) : false
    render partial: "shared/newsfeed"
  end
  
  def profile
    @user = User.find_by_username(params[:username])
    if @user.nil? || @user.locked? 
      redirect_to root_path
      return
    end 
    
    @page = params[:page].to_i
    offset = @page * 20
    if params[:task]
      @completed_tasks = [@user.completed_tasks.joins(:submitted_answer, :task).find_by_task_id(params[:task])]
      social_tags("My response to the #{@completed_tasks.first.path.name} challenge!", @user.picture)
      @compact_social = false
    else
      if params[:order] && params[:order] == "votes"
        @completed_tasks = @user.completed_tasks.offset(offset).limit(20).joins(:submitted_answer, :task).where("answer_type = ?", Task::CREATIVE).order("total_votes DESC")
      else
        @completed_tasks = @user.completed_tasks.offset(offset).limit(20).joins(:submitted_answer, :task).where("answer_type = ?", Task::CREATIVE).order("completed_tasks.created_at DESC")
      end
      social_tags("#{@user.name}'s Profile on MetaBright", @user.picture)
      @compact_social = true
    end  
    
    @completed_tasks_by_challenge = @user.completed_tasks
      .joins(:task, :path)
      .select("tasks.question, tasks.answer_type, paths.name")
      .where("tasks.answer_type = ?", Task::CHECKIN)
      .group_by(&:name)
    
    @enrolled_personas = @user.personas
    @user_personas = @user.user_personas.includes(:persona)
    
    @creative_task_questions = @completed_tasks.collect { |item| item.task }
    @enrollments = @user.enrollments.includes(:path).where("total_points > ? and paths.approved_at is not ?", 50, nil).sort { |a,b| b.total_points <=> a.total_points }
    
    @votes = current_user.nil? ? [] : current_user.votes.to_a.collect {|v| v.submitted_answer_id } 
    @title = @user.name
    @more_available_url = @completed_tasks.size == 20 ? profile_path(@user.username, page: @page+1) : false
    if request.xhr?
      render partial: "shared/newsfeed"
    end
  end
  
  def intro
    @show_nav_bar = false
    @show_footer = false
    render "intro", layout: "landing"
  end
  
  def start
    @show_nav_bar = false
    @show_footer = false
    @personas = current_company.personas.all
    render "start", layout: "landing"
  end
  
  def create
    @title = "Create" 
    @paths = current_user.paths.to_a + current_user.collaborating_paths.all(:order => "updated_at DESC").to_a
  end
  
  def mark_read
    current_user.user_events.unread.update_all(read_at: Time.now)
    render json: { status: "success" }
  end
  
  def mark_help_read
    if current_user
      current_user.set_viewed_help(params[:id])
      render json: { status: "success" }
    else
      if session[:viewed_help].nil?
        session[:viewed_help] = params[:id]
      else
        session[:viewed_help] = session[:viewed_help].split(",").push(params[:id]).join(",")
      end
      render json: { status: session[:viewed_help] }
    end
  end
  
  def about
    @title = "About"
    @show_footer = true
    render "about", layout: "landing"
  end
  
  def challenges
    @title = "Challenges"
    @show_footer = true
    @personas = current_company.personas
    render "challenges", layout: "landing"
  end
  
  def tos
    @title = "Terms of Service"
    @show_footer = true
    render "tos", layout: "landing"
  end
  
  def email_test
    raise "Access Denied" unless @enable_administration
    if params[:email]
      eval("Mailer.#{params[:test_method]}('#{params[:email]}').deliver")
      flash[:success] = "Email should have been sent."
    end
  end
  
  private
    def authorize_resource
      return true
    end
end
