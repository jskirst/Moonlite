class PagesController < ApplicationController
  include PreviewHelper
  include NewsfeedHelper
  
  before_filter :authenticate, except: [:home, :profile, :about, :challenges, :tos, :mark_help_read, :robots, :url]
  before_filter :authorize_resource, only: [:create]
  
  def home
    @title = "Home"
    if current_user and not current_user.completed_tasks.empty?
      redirect_to start and return if params[:go] == "start"
      @enrollments = current_user.enrollments.includes(:path).where("paths.approved_at is not ?", nil).sort { |a,b| b.total_points <=> a.total_points }
      @enrolled_personas = current_user.personas
      @suggested_paths = Path.suggested_paths(current_user)
    else
      @show_nav_bar = false
      @show_header = false
      @show_footer = false
      @hide_background = true
      @paths = Path.by_popularity(8).to_a
      render "origin"
    end
  end
  
  def newsfeed
    feed = Feed.new(params, current_user, newsfeed_url)
    relevant_paths = current_user.enrollments.to_a.collect(&:path_id)
    relevant_paths = Path.where(is_approved: true).first(10).to_a.collect(&:path_id) if relevant_paths.nil?
    feed.posts = CompletedTask.joins({:task => :section}, :submitted_answer)
      .where("sections.path_id in (?)", relevant_paths)
      .order("completed_tasks.created_at DESC")
      .limit(15)
      .offset(feed.page * 15)
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
      @similar_people = User.joins(:user_role)
        .joins("INNER JOIN user_personas on users.id = user_personas.user_id")
      	.where("user_roles.enable_administration = ? and users.id != ? and user_personas.persona_id = ?", false, @user.id, @current_user_persona.persona_id)
	      .where("users.image_url is not ?", nil)
      	.limit(100)
      	.to_a.shuffle
      	.first(8)
      social_tags("#{@user.name}'s Profile on Metabright", @user.picture, "#{@user.name} is a lvl. #{@current_user_persona.level} #{@current_user_persona.persona.name} on MetaBright.")
    end
  end
  
  def intro
    current_user.brand_new = true
    @hide_background = true
    @show_nav_bar = false
    @show_footer = false
    render "intro"
  end
  
  def start
    @show_nav_bar = false
    @show_footer = false
    @hide_background = true
    @personas = current_company.personas.all
    render "start"
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
    @hide_background = true
    render "about"
  end
  
  def challenges
    @title = "Challenges"
    @show_footer = true
    @hide_background = true
    @personas = current_company.personas
    render "challenges"
  end
  
  def tos
    @title = "Terms of Service"
    @show_footer = true
    @hide_background = true
    render "tos"
  end
  
  def ideas
    @title = "Ideas"
    @show_footer = true
    render "ideas"
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
