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
      if params[:m]
        @first_four_challenges = Path.where("company_id = ? and is_published = ? ", 1, true).first(4)
        @last_four_challenges = Path.where("company_id = ? and is_published = ? ", 1, true).last(4)
        render "consumer_landing", layout: "landing"
      elsif @is_company
        if @possible_company && @possible_company.enable_custom_landing
          render "company_landing"
        else
          render "landing"
        end
      else
        render "consumer_landing", layout: "landing"
      end
      return
    end
  end
  
  def start
    @personas = current_company.personas.all
    render "start", layout: "landing"
  end
  
  def explore
    @title = "Explore"
    @personas = current_user.company.personas
  end
  
  def create
    @published_paths = current_user.paths.where("is_published = ?", true).all(:order => "updated_at DESC")
    @unpublished_paths = current_user.paths.where("is_published = ?", false).all(:order => "updated_at DESC")
    if @enable_collaboration
      @collaborating_paths = current_user.company.paths.all(:order => "updated_at DESC")
    else
      @collaborating_paths = current_user.collaborating_paths.all(:order => "updated_at DESC")
    end
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
