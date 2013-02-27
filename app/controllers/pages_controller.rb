class PagesController < ApplicationController
  include PreviewHelper
  include NewsfeedHelper
  
  before_filter :authenticate, except: [:home, :profile, :about, :challenges, :tos, :mark_help_read, :robots, :url]
  before_filter :authorize_resource, only: [:create]
  
  def home
    @title = "Home"
    if signed_in?
      redirect_to start and return if params[:go] == "start"
      @enrollments = current_user.enrollments.includes(:path).where("paths.approved_at is not ?", nil).sort { |a,b| b.total_points <=> a.total_points }
      @enrolled_personas = current_user.personas
      @suggested_paths = Path.suggested_paths(current_user)
    else
      @show_header = false
      @personas = Persona.all
      render "landing", layout: "landing"
    end
  end
  
  def newsfeed
    feed = Feed.new(params, current_user, newsfeed_url)
    relevant_paths = current_user.enrollments.to_a.collect(&:path_id)
    if relevant_paths.empty?
      feed.posts = CompletedTask.joins(:task, :submitted_answer)
        .order("completed_tasks.created_at DESC")
        .limit(15)
        .offset(feed.page * 15)
    else
      feed.posts = CompletedTask.joins({:task => :section}, :submitted_answer)
        .where("sections.path_id in (?)", relevant_paths)
        .order("completed_tasks.created_at DESC")
        .limit(15)
        .offset(feed.page * 15)
    end
    render partial: "newsfeed/feed", locals: { feed: feed }
  end
  
  def profile
    @user = User.find_by_username(params[:username])
    if @user.nil? || @user.locked? 
      redirect_to root_path
      return
    end
    
    @user_personas = @user.user_personas.includes(:persona).sort{ |a, b| b.level <=> a.level }
    if params[:p].blank?
      @current_user_persona = @user_personas.first
    else
      @current_user_persona = @user_personas.select{ |up| up.persona_id == params[:p].to_i }.first
    end
    
    if @current_user_persona
      @enrollments = @current_user_persona.enrollments.sort{ |a, b| b.total_points <=> a.total_points }
      @similar_people = User.joins("INNER JOIN user_personas on users.id = user_personas.user_id")
        .where("users.id != ? and user_personas.persona_id = ?", @user.id, @current_user_persona.persona_id)
        .limit(4)
    end
    
    @title = @user.name
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
  
  def ideas
    @title = "Ideas"
    @show_footer = true
    render "ideas", layout: "landing"
  end
  
  def email_test
    raise "Access Denied" unless Rails.env == "development" or ENV['ENABLE_EMAIL_TEST']
    if params[:email] && params[:test_method] && params[:mailer]
      eval("#{params[:mailer]}.#{params[:test_method]}('#{params[:email]}').deliver")
      flash[:success] = "Email should have been sent."
    end
  end
  
  def robots
    robots = File.read(Rails.root + "config/robots.#{Rails.env}.txt")
    render text: robots, layout: false, content_type: "text/plain"
  end
  
  def preview
    url = params[:url]
    preview = parse_url_for_preview(url)
    
    render json: { data: preview.to_json }
  end
  
  private
  
  def authorize_resource
    return true
  end
end
