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
      @enrollments.each do |e|
        @newsfeed_items << e.path.completed_tasks.joins(:submitted_answer).all(order: "completed_tasks.created_at DESC", limit: 30)
      end
      @newsfeed_items = @newsfeed_items.flatten.sort { |a, b| a.created_at <=> b.created_at }
      render "users/home"
    else
      render "landing", layout: "landing"
    end
  end
  
  def intro
    render "intro", layout: "landing"
  end
  
  def start
    @personas = current_company.personas.all
    render "start", layout: "landing"
  end
  
  def create
    @paths = current_user.paths.to_a + current_user.collaborating_paths.all(:order => "updated_at DESC").to_a
  end
  
  def about
    @no_bar = false
    @show_footer = true
    render "about", layout: "landing"
  end
  
  def challenges
    @personas = current_company.personas
    @no_bar = false
    @show_footer = true
    render "challenges", layout: "landing"
  end
  
  def tos
    @no_bar = false
    @show_footer = true
    render "tos", layout: "landing"
  end
  
  def email_test
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
