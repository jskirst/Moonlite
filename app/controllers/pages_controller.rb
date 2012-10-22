class PagesController < ApplicationController
  before_filter :authenticate, :only => [:explore, :start]
  before_filter :user_creation_enabled?, :only => [:create]
  before_filter :browsing_enabled?, :only => [:explore]
  
  def home
    @title = "Home"
    if signed_in?
      redirect_to start and return if params[:go] == "start"
      @enrolled_paths = current_user.enrolled_paths
      @enrolled_personas = current_user.personas
      @suggested_paths = Path.suggested_paths(current_user)
      @votes = current_user.votes.to_a.collect {|v| v.submitted_answer_id } 
      @newsfeed_items = []
      @enrolled_paths.each do |p|
        @newsfeed_items << p.completed_tasks.joins(:submitted_answer).all(order: "completed_tasks.created_at DESC", limit: 10)
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
  
  def invitation
    @title = "Request an invite"
    if params[:pages] && params[:pages][:email]
      send_invitation_alert(params[:pages][:email])
      render "invitation_sent"
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
