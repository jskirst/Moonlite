class PagesController < ApplicationController
  before_filter :authenticate, except: [:home, :about, :challenges, :tos, :mark_help_read]
  before_filter :authorize_resource, only: [:create]
  
  def home
    @title = "Home"
    if signed_in?
      redirect_to start and return if params[:go] == "start"
      @enrollments = current_user.enrollments.includes(:path).sort { |a,b| b.total_points <=> a.total_points }
      @enrolled_personas = current_user.personas
      @suggested_paths = Path.suggested_paths(current_user)
      render "users/home"
    else
      @show_sign_in = false
      render "landing", layout: "landing"
    end
  end
  
  def newsfeed
    @votes = current_user.votes.to_a.collect {|v| v.submitted_answer_id } 
    @newsfeed_items = []
    @page = params[:page].to_i
    relevant_paths = current_user.enrollments.to_a.collect &:path_id
    if relevant_paths.empty?
      @newsfeed_items = CompletedTask.joins(:task, :submitted_answer)
        .where("tasks.answer_type = ?", Task::CREATIVE)
        .order("completed_tasks.created_at DESC")
        .limit(30)
        .offset(@page * 30)
    else
      @newsfeed_items = CompletedTask.joins({:task => :section}, :submitted_answer)
        .where("sections.path_id in (?) and tasks.answer_type = ?", relevant_paths, Task::CREATIVE)
        .order("completed_tasks.created_at DESC")
        .limit(30)
        .offset(@page * 30)
    end
    @more_available = @newsfeed_items.size == 30
    @more_available_url = newsfeed_path(page: @page+1)
    render partial: "shared/newsfeed", locals: { newsfeed_items: @newsfeed_items }
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
    @paths = current_user.paths.to_a + current_user.collaborating_paths.all(:order => "updated_at DESC").to_a
  end
  
  def mark_read
    current_user.user_events.update_all(is_read: true)
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
    @show_footer = true
    render "about", layout: "landing"
  end
  
  def challenges
    @show_footer = true
    @personas = current_company.personas
    render "challenges", layout: "landing"
  end
  
  def tos
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
      unless @enable_content_creation
        flash[:error] = "You do not have access to #{name_for_paths} editing functionality."
        redirect_to root_path
      end
    end
end
