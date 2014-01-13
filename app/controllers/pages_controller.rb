class PagesController < ApplicationController
  include PreviewHelper
  include NewsfeedHelper
  include HamsterPowered::HamsterHelper
  
  before_filter :authenticate, only: [:create]
  
  def home
    @title = "Skill Tests"
    @url_for_newsfeed 
    if @admin_group and not @admin_group.requires_payment?
      @group = @admin_group
      @group_custom_style = @group.custom_style
      if current_user.guest_user?
        @show_nav_bar = false
        set_return_back_to = confirmation_group_url(@group)
      end
      @hide_background = true
      render "portal"
    elsif current_user and not current_user.earned_points == 0
      redirect_to start and return if params[:go] == "start"
      @enrollments = current_user.enrollments.includes(:path).where("paths.approved_at is not ?", nil).references(:path).sort { |a,b| b.total_points <=> a.total_points }
      @enrolled_personas = current_user.personas
      @suggested_paths = Path.suggested_paths(current_user)
    elsif request.original_url.include?("employers.metabright.com") and session[:viewed_evaluator].nil?
      session[:viewed_evaluator] = true
      redirect_to evaluator_path
    else
      @show_chat = true
      @show_user_name = true
      @show_nav_bar = true
      @show_header = false
      @show_footer = false
      @hide_background = true
      @paths = Path.by_popularity(21).where("promoted_at is not ?", nil).to_a
      render "upheaval"
    end
  end
  
  def newsfeed
    feed = Feed.new(path: @path, 
      page: params[:page], 
      context: params[:context], 
      user: current_user, 
      url: newsfeed_url(order: params[:order]))

    offset = feed.page * 15
    relevant_paths = current_user.enrollments.to_a.collect(&:path_id)
    #raise relevant_paths.to_yaml
    eval_paths = current_user.evaluation_enrollments.to_a.collect{|er| er.evaluation.paths.pluck(:id)}.flatten
    #raise eval_paths.to_yaml
    relevant_paths = Path.where(is_approved: true).first(10).to_a.collect(&:path_id) if relevant_paths.nil?
    feed.submissions = CompletedTask.joins(:submitted_answer, :user, :task => :path)
      .select(newsfeed_fields)
      .where("paths.id in (?)", relevant_paths)
      .where("paths.group_id is ?", nil)
      .where("completed_tasks.status_id = ?", Answer::CORRECT)
      .where("submitted_answers.locked_at is ?", nil)
      .where("submitted_answers.reviewed_at is not ?", nil)

    if eval_paths.any?
      feed.submissions = feed.submissions.where("paths.id not in (?)", eval_paths)
    end

    if params[:order] == "hot"
      feed.submissions = feed.submissions.select("((submitted_answers.total_votes + 1) - ((current_date - DATE(completed_tasks.created_at))^2) * .1) as hotness").order("hotness DESC")
    elsif params[:order] == "halloffame"
      feed.submissions = feed.submissions.where("submitted_answers.promoted_at is not ?", nil).order("submitted_answers.id DESC")
    elsif params[:order] == "following"
      user_ids = current_user.subscriptions.collect(&:followed_id)
      feed.submissions = feed.submissions.where("users.id in (?)", user_ids).order("completed_tasks.id DESC")
    else
      feed.submissions = feed.submissions.order("completed_tasks.created_at DESC")
    end
    feed.submissions = feed.submissions.limit(15).offset(offset)
    
    render partial: "newsfeed/feed", locals: { feed: feed }
  end
  
  def profile
    @user = User.where(username: params[:username]).first
    if @user.nil?
      flash[:error] = "User could not be found."
      redirect_to root_url and return
    elsif @user.locked? or (@user.private? and @user != current_user)
      redirect_to root_path and return
    end

    @title = @user.name
    @user_custom_style = @user.custom_style
    @groups = @user.groups.where(is_private: false)
    @user_personas = @user.user_personas.includes(:persona).to_a.delete_if{ |up| up.total_points == 0 }.sort{ |a, b| b.level <=> a.level }
    if params[:persona].blank?
      @current_user_persona = @user_personas.first
    else
      @current_user_persona = @user_personas.select{ |up| up.persona_id == params[:persona].to_i }.first
      @current_user_persona = @user_personas.first if @user_personas.first
    end
    
    if @current_user_persona
      @enrollments = @current_user_persona.enrollments.includes(:path).sort{ |a, b| b.total_points <=> a.total_points }
      completed_tasks = CompletedTask.joins(:user, :task => :path)
        .joins("LEFT JOIN topics on tasks.topic_id = topics.id")
        .joins("LEFT JOIN submitted_answers on submitted_answers.id=completed_tasks.submitted_answer_id")
        .select(newsfeed_fields)
        .select("topics.name as topic_name")
        .where("completed_tasks.status_id = ?", Answer::CORRECT)
        .where("submitted_answers.locked_at is ?", nil)
        .where("(submitted_answers.id is ? or submitted_answers.reviewed_at is not ?)", nil, nil)
        .where("users.id = ?", @user.id)
        .order("completed_tasks.points_awarded DESC")
        .to_a
      
      @enrollment_details = {}
      @enrollments.each do |e|
        core = completed_tasks.select{ |ct| ct.path_id == e.path_id and (ct.answer_type == Task::MULTIPLE or ct.answer_type == Task::EXACT) }
        creative = completed_tasks.select{ |ct| ct.path_id == e.path_id and ct.answer_type == Task::CREATIVE }
        tasks = completed_tasks.select{ |ct| ct.path_id == e.path_id and ct.answer_type == Task::CHECKIN }
        votes = 0
        comments = 0
        (creative+tasks).each do |ct|
          comments += ct.total_comments.to_i if ct.total_comments != "0"
          votes += ct.total_votes.to_i if ct.total_votes != "0"
        end
        
        @enrollment_details[e.path_id] = {
          core: core,
          topics: core.collect{|ct| ct.topic_name if ct.status_id == Answer::CORRECT }.compact.uniq,
          votes: votes,
          comments: comments,
          creative: Feed.new(page: params[:page], action: params[:action], user: current_user, submissions: creative),
          tasks: Feed.new(page: params[:page], action: params[:action], user: current_user, submissions: tasks)
        }
      end
      
      @tasks = Task.joins(:section => :path)
        .where("tasks.creator_id = ?", @user.id)
        .select("tasks.*, paths.id as path_id, paths.image_url, paths.name, paths.user_id, paths.approved_at as path_approved")
        .to_a
      @contributions = {}
      unless @tasks.empty?
        @tasks.each do |t|
          if @contributions[t.path_id]
            @contributions[t.path_id][:count] += 1
          else
            @contributions[t.path_id] = {
              user_id: t.user_id,
              count: 0,
              name: t.name,
              image_url: t.image_url,
              primary: false,
              users: 0,
              approved: t.path_approved
            }
          end
        end
        @contributions.delete_if{ |key, values| values[:approved].nil? }
        @contributions.each do |key, c|
          @contributions[key][:users] = Enrollment.where("path_id = ?", key).count
          @contributions[key][:primary] = c[:user_id] == @user.id.to_s or Collaboration.find_by_user_id(@user.id)
        end
        @contributions = @contributions.values
      end
      
      @similar_people = User.joins("INNER JOIN user_personas on users.id = user_personas.user_id")
        .where("users.locked_at is ? and users.private_at is ?", nil, nil)
      	.where("users.enable_administration = ? and users.id != ? and user_personas.persona_id = ?", false, @user.id, @current_user_persona.persona_id)
	      .where("users.image_url is not ?", nil)
      	.limit(100)
      	.to_a.shuffle
      	.first(8)
      social_tags("#{@user.name}'s MetaBright profile", @user.picture, "#{@user.name} is a lvl. #{@current_user_persona.level} #{@current_user_persona.persona.name} on MetaBright.")
    end
  end
  
  def intro
    @hide_background = true
    @show_nav_bar = false
    @show_footer = false
    @forward_to = continue_path_path(params[:c])
    render "intro"
  end
  
  def start
    @show_nav_bar = false
    @show_footer = false
    @hide_background = true
    @personas = Persona.all
    render "start"
  end
  
  def mark_read
    current_user.user_events.unread.each{ |ue| ue.update_attribute(:read_at, Time.now) }
    render json: { status: "success" }
  end
  
  def about
    @title = "About"
    @show_footer = true
    @hide_background = true
    render "about"
  end
  
  def internship
    @title = "Internship"
    @show_footer = true
    @hide_background = true
    render "internship"
  end
  
  def employers
    @title = "Hiring solutions for employers"
    @show_footer = true
    @hide_background = true
    render "employers"
  end
  
  def talentminer
    @title = "Talent Miner"
    @show_footer = true
    @hide_background = true
    render "talentminer"
  end
  
  def airs_landing
    @title = "MetaBright Welcomes AIRS Training Students"
    @show_chat = true
    @show_user_name = false
    @show_nav_bar = false
    @show_header = false
    @show_footer = false
    @hide_background = true
    @paths = Path.by_popularity(24).where("promoted_at is not ?", nil).to_a
    render "airs_landing"
  end
  
  def evaluator
    if @admin_group and @admin_group.stripe_token.present?
      redirect_to root_url and return
    end
    @title = "Pre-Employment Skill Tests - MetaBright Evaluator"
    @show_footer = true
    @hide_background = true
    @show_sign_in = true
    @show_nav_bar = true
    @show_chat = true
    @show_employer_link = false
    @paths = Path.where("professional_at is not NULL").to_a
  end
  
  def pricing
    if @admin_group and @admin_group.stripe_token.present?
      redirect_to root_url and return
    end
    @title = "Pre-Employment Skill Tests - MetaBright Evaluator"
    @show_footer = true
    @show_chat = true
    @hide_background = true
    @show_sign_in = true
    @show_nav_bar = true
    @show_employer_link = false
  end
  
  def promo_pricing
    if @admin_group and @admin_group.stripe_token.present?
      redirect_to root_url and return
    end
    @title = "Pre-Employment Skill Tests - MetaBright Evaluator"
    @show_footer = true
    @show_chat = true
    @hide_background = true
    @show_sign_in = true
    @show_nav_bar = false
    @show_employer_link = false
  end
  
  def challenges
    @title = "Challenges"
    @show_footer = true
    @hide_background = true
    @personas = Persona.all
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
  
  def sitemap
    redirect_to "https://s3-us-west-1.amazonaws.com/moonlite/sitemaps/sitemap.xml.gz"
  end
  
  def preview
    url = params[:url]
    preview = parse_url_for_preview(url)
    
    #raise preview.to_yaml
    render json: { data: preview.to_json }
  end
  
  def bad
    raise "This is not valid."
  end
  
  def streaming
    tests = []
    10.times { tests << ProcessingTest.new(0.3) }
    render as_processing_screen(tests, :run_test, root_path)
  end

  def userevents
    @user_events = UserEvent.order("id DESC").first(100)
  end
  
  private
  
  class ProcessingTest
    def initialize(num)
      @num = num
    end
    
    def run_test
      sleep @num
    end
  end
  
  def admin_only
    unless Rails.env == "development" or @enable_administration
      raise "Access Denied: In development"
    end
  end
  
  def authorize_resource
    return true
  end
end
