class PagesController < ApplicationController
  before_filter :authenticate, :only => [:explore, :start]
  before_filter :user_creation_enabled?, :only => [:create]
  before_filter :browsing_enabled?, :only => [:explore]
  
  def home
    @title = "Home"
    if signed_in?
      @paths = current_user.enrolled_paths.where("is_published = ?", true)
      @enrolled_paths = []
      @completed_paths = []
      @paths.each do |p|
        if p.completed?(current_user)
          @completed_paths << p
        else
          @enrolled_paths << p
        end
      end
      if @enable_recommendations
        @suggested_paths = Path.suggested_paths(current_user)        
      end
      @user_events = UserEvent.includes(:user, :company, :path).where("companies.id = ? and users.user_role_id = ?", current_user.company_id, current_user.user_role_id).all(:limit => 20, :order => "user_events.created_at DESC")
    else
      if params[:m]
        @first_four_challenges = Path.where("company_id = ? and is_published = ? ", 1, true).first(4)
        @last_four_challenges = Path.where("company_id = ? and is_published = ? ", 1, true).last(4)
        render "consumer_landing", layout: false
      elsif @is_company
        if @possible_company && @possible_company.enable_custom_landing
          render "company_landing"
        else
          render "landing"
        end
      else
        render "landing"
      end
      return
    end
  end
  
  def start
    @personas = current_company.personas.all
    @personas = current_company.personas.all
    @persona = @personas.first
    @paths = @persona.paths
    render "getting_started", layout: false
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
