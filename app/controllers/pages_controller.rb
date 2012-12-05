class PagesController < ApplicationController
  before_filter :authenticate, :only => [:explore, :start]
  before_filter :user_creation_enabled?, :only => [:create]
  before_filter :browsing_enabled?, :only => [:explore]
  
  def home
    @title = "Home"
    if signed_in?
      redirect_to start and return if params[:go] == "start"
      @enrollments = current_user.enrollments.includes(:path)
      @enrolled_personas = current_user.personas
      @suggested_paths = Path.suggested_paths(current_user)
      @votes = current_user.votes.to_a.collect {|v| v.submitted_answer_id } 
      @newsfeed_items = []
      challenge_questions = current_user.completed_tasks
        .joins(:task)
        .where("tasks.answer_type = ?", Task::CREATIVE)
        .select(:section_id)
        .to_a.collect &:section_id
      unless challenge_questions.empty?
        @page = params[:page].to_i
        @newsfeed_items = CompletedTask.joins(:task, :submitted_answer)
          .where("tasks.section_id in (?)", challenge_questions)
          .order("completed_tasks.created_at DESC")
          .limit(30)
          .offset(@page * 30)
        @more_available = @newsfeed_items.size == 30
      end
      if request.xhr?
        render partial: "shared/newsfeed", locals: { newsfeed_items: @newsfeed_items }
      else
        render "users/home"
      end
    else
      @show_sign_in = false
      render "landing", layout: "landing"
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
    @paths = current_user.paths.to_a + current_user.collaborating_paths.all(:order => "updated_at DESC").to_a
  end
  
  def mark_read
    current_user.user_events.update_all(is_read: true)
    render json: { status: "success" }
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
    raise "FUCK NO" unless @enable_administration
    if params[:email]
      eval("Mailer.#{params[:test_method]}('#{params[:email]}').deliver")
      flash[:success] = "Email should have been sent."
    end
  end
  
  private
    def send_invitation_alert(email)
      Mailer.invitation_alert(email).deliver
    end
    
    def user_creation_enabled?
      unless @enable_user_creation
        flash[:error] = "You do not have access to #{name_for_paths} editing functionality."
        redirect_to root_path
      end
    end
    
    def browsing_enabled?
      unless @enable_browsing
        flash[:error] = "You do not have access to #{name_for_paths} browsing functionality."
        redirect_to root_path
      end
    end
end
