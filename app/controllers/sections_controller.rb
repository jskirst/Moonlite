require 'net/http'
require 'uri'
require 'fileutils.rb'

class SectionsController < ApplicationController
  include SectionsHelper
  
  before_filter :authenticate
  before_filter :has_edit_access?, except: [:show, :continue, :results]
  before_filter :get_section_from_id, except: [:new, :create, :generate]
  before_filter :can_edit?, except: [:show, :continue, :results, :new, :create, :generate] 
  before_filter :enrolled?, only: [:continue, :results, :chose, :take, :took]
  
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

# Begin Section Journey

  def launchpad
    @current_section = @section
    @unlocked = @section.unlocked?(current_user)
    render partial: "launchpad"
  end

  def chose
    @tasks = @section.tasks
    @completed_tasks = @section.completed_tasks.where("user_id = ?", current_user.id).to_a.collect { |cp| cp.task_id } 
  end
  
  def take
    @task = @section.tasks.find(params[:task_id])
    @path = @section.path
    @answers = @task.answers
    @answers = @answers.to_a.shuffle unless @answers.empty?
    @stored_resource = @task.stored_resources.first
  end
  
  def took
    task = @section.tasks.find(params[:task_id])
    raise "Task already completed" if current_user.completed_tasks.find_by_task_id(task.id)
    if params[:answer].blank? && params[:text_answer].blank?
      flash.now[:error] = "You must provide an answer."
      redirect_to take_section_path(@section, task_id: task.id)
    end
    
    ct = current_user.completed_tasks.new()
    ct.task_id = task.id
    if task.answer_type == 0
      ct.status_id = 2
      submitted_answer = task.find_or_create_submitted_answer(params[:answer])
      ct.submitted_answer_id = submitted_answer.id 
      flash[:success] = "Answer submitted to the community."
    elsif task.answer_type >= 1
      ct.answer = params[:answer]
      status_id, chosen_answer = task.is_correct?(ct.answer)
      ct.status_id = status_id
      ct.answer_id = chosen_answer.id unless chosen_answer.nil?
    else
      raise "RUNTIME EXCEPTION: Invalid answer type for Task ##{task.id.to_s}"
    end
    
    if status_id == 1
      flash[:success] = "Correct!"
      points = 10
      ct.points_awarded = points
      current_user.award_points(task, points)
    else
      ct.points_awarded = 0
    end
    
    if ct.save
      Answer.increment_counter(:answer_count, chosen_answer.id) if chosen_answer
    else
      flash[:error] = @ct.errors.full_messages.join(", ")
    end
    redirect_to community_path_path(@section.path, completed: true)
  end
  
  def continue
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
      if @path.enable_retakes
        generate_hint
      else
        @hints = []
      end
      @stored_resource = @task.stored_resources.first
      if @correct
        @leaderboard = Leaderboard.includes(:user).where("path_id = ? and score < ? and score > ?", @path.id, @earned_points, @earned_points - 10).first
      end
      
      @time_allotted = get_time_remaining(@task)
      
      if params[:task_id].nil?
        render "start" 
      else
        render :partial => "continue", :locals => @locals
      end
    else
      if current_company.id == 1
        redirect_url = "Redirecting to results:" + community_path_url(@section.path, completed: "true")
      else
        redirect_url = "Redirecting to results:" + continue_path_url(@section.path)
      end
      render :text => redirect_url
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