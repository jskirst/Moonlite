require 'net/http'
require 'uri'
require 'fileutils.rb'

class SectionsController < ApplicationController
  include OrderHelper
  include GeneratorHelper
  include SectionsHelper
  
  before_filter :authenticate
  before_filter :has_edit_access?, :except => [:show, :continue, :results]
  before_filter :get_section_from_id, :except => [:new, :create, :generate]
  before_filter :can_edit?, :except => [:show, :continue, :results, :new, :create, :generate] 
  before_filter :enrolled?, :only => [:continue, :results]
  
  respond_to :json, :html

  def show
    if current_user.enrolled?(@section.path) && @section.enable_skip_content
      redirect_to continue_section_path(@section)
    else
      @path_name = @section.path.name
      @title = @section.name
      @section_started = current_user.section_started?(@section)
      @stored_resources = @section.stored_resources.all
    end
  end

# Begin Section Creation  
  
  def new
    @section = Section.new
    @title = "New section"
    @path = Path.find(params[:path_id])
    unless can_edit_path(@path)
      flash[:error] = "You cannot add sections to this #{name_for_paths}."
      redirect_to root_path
      return
    end
    @section.path = @path
  end
  
  def create
    @path_id = params[:section][:path_id]
    @path = Path.find_by_id(@path_id)
    if @path.nil?
      flash[:error] = "No #{name_for_paths} selected for section."
      redirect_to root_path and return
    else
      unless can_edit_path(@path)
        flash[:error] = "You cannot add tasks to this #{name_for_paths}."
        redirect_to root_path
        return
      end
      @section = @path.sections.build(params[:section])
      if @section.save
        flash[:success] = "Section created."
        redirect_to edit_path_path(@path)
      else
        @title = "New section"
        @form_title = @title
        @path_id = @path.id
        render "new"
      end
    end
  end

# Begin Section Edit
  
  def edit
    @path_id = @section.path_id
    if params[:m] == "tasks"
      @task = @section.tasks.new
      @tasks = @section.tasks.all(:order => "id DESC")
      @display = (@tasks.empty?)
      respond_to do |f|
        f.html { render :partial => "edit_tasks", :locals => { :display_new_task_form => @display, :task => @task, :tasks => @tasks, :section => @section } }
      end
    elsif params[:m] == "settings"
      respond_to do |f|
        f.html { render :partial => "edit_settings", :locals => { :section => @section } }
      end
    elsif params[:m] == "content"
      @stored_resources = @section.stored_resources
      respond_to do |f|
        f.html { render :partial => "edit_content", :locals => { :section => @section, :stored_resources => @stored_resources } }
      end
    end
  end
  
  def update
    if @section.update_attributes(params[:section])
      flash[:success] = "Section successfully updated."
    else
      flash[:error] = "Section could not be updated updated."
    end
    redirect_to edit_path_path(@section.path)
  end
  
  def publish
    if @section.tasks.count.zero?
      flash[:error] = "You need to have at least one question before you can make your section publicly available."
    else
      @section.is_published = true
      if @section.save
        flash[:success] = "#{@section.name} has been successfully published. Note that if you have not already, you will still need to publish the #{name_for_paths.downcase} as a whole before it will be visible to the community."
      else
        flash[:error] = "There was an error publishing."
      end
    end
    redirect_to edit_path_path(@section.path)
  end
  
  def unpublish
    other_sections = @section.path.sections.where("is_published = ? and id != ?", true, @section.id)
    if other_sections.size < 1
      flash[:error] = "You cannot unpublish a section if it is the only one. You must unpublish the whole #{name_for_paths}."
    else
      @section.is_published = false
      if @section.save
        flash[:success] = "#{@section.name} has been successfully unpublished. It will no longer be visible."
      else
        flash[:error] = "There was an error unpublishing."
      end
    end
    redirect_to edit_path_path(@section.path)
  end
  
  def reorder_tasks
    old_order = @section.tasks.map { |t| [t.id, t.position] }
    new_order = params[:tasks][:positions].map { |id, position| [id.to_i, position.to_i] }
    revised_order = reorder(old_order, new_order)
    revised_order.each do |t|
      @section.tasks.find(t[0]).update_attribute(:position, t[1])
    end
    redirect_to edit_section_path(@section, :m => "tasks")
  end
  
  def confirm_delete
  end
  
  def destroy
    @section.destroy
    flash[:success] = "Section successfully deleted."
    redirect_to edit_path_path(@section.path, :m => "sections")
  end

# Begin Section Construction

  def import_content
    if params[:previous]
      StoredResource.delete(params[:previous])
    end
    render "import_content"
  end
  
  def preview_content
    @stored_resource = @section.stored_resources.new(:obj => params[:section][:file])
    if @stored_resource.save
      render "preview_content"
    else
      flash[:error] = "Could not load content. Please try again."
      render "import_content"
    end
  end
  
  def html_editor
  end
  
  def research
    @mode = params[:m]
    if params[:m] == "clear"
      if @section.update_attribute("instructions", nil)
        flash[:success] = "Instructions cleared."
      else
        flash[:error] = "Oops! An error occurred and we couldn't clear your instructions. Please try again."
      end
      redirect_to edit_section_path(@section, :m => "instructions")
    elsif params[:m] == "create"
      @topics = params[:topics].split(",")
      if params[:main_topic]
        @topics << @section.name
      end
      @topics = @topics.map {|t| t.strip}
      @quoted_topics = @topics.map {|t| '"'+t+'"'}
      
      @use_wikipedia = params[:use_wikipedia] ? true : false;
      @use_youtube = params[:use_youtube] ? true : false;
      @use_google_images = params[:use_google_images] ? true : false;
    elsif params[:m] == "topics"
      @answers = []
      @section.tasks.all.each do |t|
        @answers << t.describe_correct_answer
      end
      @answers = @answers.uniq.join(", ")
      render "research_settings"
    else
      @topics = []
      @quoted_topics = []
    end
  end
  
  def questions
    @title = "Generate Questions"
    @url = "http://ec2-50-19-152-110.compute-1.amazonaws.com:3000/generate"
    @limit = params[:limit]
    if params[:hidden_content]
      text = clean_text(@section.hidden_content)
    else
      text = clean_text(@section.instructions)
    end
    if text.nil?
      flash[:info] = "You need to add some content to your section before we can automatically generate tasks for you."
      redirect_to edit_section_path(@section, :m => "instructions")
    else
      @split_paragraphs = split_and_clean_text(text)
      @quoted_paragraphs = @split_paragraphs.map {|t| '"'+t+'"'}
    end
  end
  
  def generate
    @text = params[:text]
    uri = URI.parse("http://ec2-50-19-152-110.compute-1.amazonaws.com:3000/generate")
    http = Net::HTTP.new(uri.host, uri.port)

    http.read_timeout = 90
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({'text' => @text})
    resp, @data = http.request(request)
    
    unless @data.nil?
      logger.debug @data
      respond_to do |format|
        format.json
      end
    end
  end
  
  def review
    @title = "Review Questions"
    raw_questions = params[:questions]
    @processed_questions = {}
    raw_questions.each do |key, value|
      value = value.split("?")
      question = value[0].to_s + "?"
      answer = value[1].to_s
      @processed_questions[key] = {:question => question, :answer1 => answer}
    end
    logger.debug "PQ:"
    logger.debug @processed_questions.to_s
  end
  
  def bulk_tasks
    raw_questions = params[:questions]
    @processed_questions = {}
    raw_questions.each do |key, values|
      new_task = @section.tasks.build(values.merge(:points => 10))
      unless new_task.save
        @processed_questions[key] = values.merge(:errors => new_task.errors.full_messages)
      end
    end
    if @processed_questions.size > 0
      flash[:error] = "Could not save the following tasks. Please review and resubmit."
      render "review"
    else
      flash[:success] = "All tasks successfully added!"
      redirect_to edit_section_path(@section, :m => "tasks")
    end
  end

# Begin Section Journey
  
  def continue
    start_time = Time.now
    last_question, @streak, @streak_points, @streak_name = create_completed_task
    @streak ||= @section.user_streak(current_user)
    @task = @section.next_task(current_user)
    
    if @task
      @answers = @task.answers
      unless @answers.empty?
        @answers = @answers.to_a.shuffle
      end
      if last_question
        @free_response = last_question.status_id == 2
        @correct = last_question.status_id == 1
        @points_awarded = last_question.points_awarded
      end
      @progress = @path.percent_complete(current_user) + 1
      @earned_points = current_user.enrollments.find_by_path_id(@path.id).total_points
      @possible_points = 10
      if @streak < 0
        @possible_points = @possible_points/(-1*@streak)
      end
      generate_hint if @path.enable_retakes
      @stored_resource = @task.stored_resources.first
      @must_register = true if current_user.is_anonymous
      if @correct
        @leaderboard = Leaderboard.includes(:user).where("path_id = ? and score < ? and score > ?", @path.id, @earned_points, @earned_points - 10).first
      end
      
      @time_allotted = get_time_remaining(@task)
      
      if params[:task_id].nil?
        render "start" 
      else
        render :partial => "continue", :locals => @locals
      end
      logger.debug "CONTINE TIME ELAPSED:" + (Time.now - start_time).to_s
    else
      redirect_url = "Redirecting to results:" + continue_path_url(@section.path)
      render :text => redirect_url
      logger.debug "CONTINE TIME ELAPSED:" + (Time.now - start_time).to_s
      return
    end
  end
  
  private
    def has_edit_access?
      unless @enable_user_creation
        flash[:error] = "You do not have the ability to edit this section."
        redirect_to root_path
      end
    end
  
    def enrolled?
      unless current_user.enrolled?(@section.path)
        flash[:warning] = "You must be enrolled in a path before you can begin."
        redirect_to root_path
      end
    end
    
    def get_section_from_id
      @section = Section.find(params[:id], :include => :path)
      @path = @section.path
    end
    
    def can_edit?
      unless can_edit_path(@section.path)
        flash[:error] = "You do not have access to this Path. Please contact your administrator to gain access."
        redirect_to root_path
      end
    end
end