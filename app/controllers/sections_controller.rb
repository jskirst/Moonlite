require 'net/http'
require 'uri'
require 'fileutils.rb'

class SectionsController < ApplicationController
  before_filter :authenticate
  #before_filter :has_edit_access?, except: [:show, :continue, :results]
  before_filter :get_section_from_id, except: [:new, :create, :generate]
  #before_filter :can_edit?, except: [:show, :continue, :complete, :launchpade, :new, :create] 
  before_filter :enrolled?, only: [:complete, :continue, :take, :took]

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

# Begin Section Journey

  def launchpad
    @current_section = @section
    @unlocked = @section.unlocked?(current_user)
    if @unlocked
      @tasks = @current_section.tasks
        .joins("LEFT OUTER JOIN completed_tasks on completed_tasks.task_id = tasks.id")
        .select("status_id, question, tasks.id, points_awarded, answer_type, answer_sub_type")
      @core_tasks = @tasks.select { |t| t.answer_type == Task::MULTIPLE }
      @challenge_tasks = @tasks.select { |t| t.answer_type == Task::CREATIVE }
      @achievement_tasks = @tasks.select { |t| t.answer_type == Task::CHECKIN }
    end
    @display_type = params[:type] || 2
    render partial: "launchpad"
  end
  
  def take
    @show_nav_bar = false
    @show_footer = false
    @task = @section.tasks.find(params[:task_id])
    raise "Not a challenge." unless @task.is_challenge_question?
    @path = @section.path
    @stored_resource = @task.stored_resources.first
  end
  
  def took
    task = @section.tasks.find(params[:task_id])
    raise "Task already completed" if current_user.completed_tasks.find_by_task_id(task.id)
    raise "Only CRs can be taken." unless task.is_challenge_question?
    
    if !params[:answer].blank? || params[:answer] != "false" || params[:obj]
      unless params[:obj]
        submitted_answer = task.submitted_answers.create!(content: params[:answer])
      else
        submitted_answer = task.submitted_answers.create!
        sr = submitted_answer.stored_resources.new(params)
        sr.save
        submitted_answer.content = sr.obj.url
        submitted_answer.save
      end
      ct = current_user.completed_tasks.create!(
        points_awarded: 100, 
        task_id: task.id, status_id: 1, 
        submitted_answer_id: submitted_answer.id)
      current_user.award_points(task, 100)
      redirect_to path_path(@section.path, completed: true, type: task.answer_type)
    else
      redirect_to path_path(@section.path), alert: "You must supply a valid answer."
    end
  end
  
  def complete
    ct = current_user.completed_tasks.find_by_task_id(params[:task_id])
    results = ct.complete_multiple_choice(params[:answer], params[:points_remaining].to_i)
    render json: results
  end
    
  def continue
    @show_nav_bar = false
    @show_footer = false
    @task = @section.next_task(current_user)
    @enrollment = current_user.enrollments.find_by_path_id(@path.id)
    if @task
      calculate_streak
      @completed_task = current_user.completed_tasks.create!(task_id: @task.id, status_id: Answer::INCOMPLETE)
      @answers = @task.answers.to_a.shuffle
      @progress = @section.percentage_complete(current_user) + 1
      @stored_resource = @task.stored_resources.first
      
      if request.get?
        @partial = current_user.earned_points == 0 ? "intro" : "continue"
        render "start" 
      else
        render :partial => "continue"
      end
    else
      @available_crs = @section.tasks.where("answer_type = ?", Task::CREATIVE).size
      @unlocked_sections = @path.sections.where("points_to_unlock <= ?", @enrollment.total_points).size 
      Leaderboard.reset_for_path_user(@path, current_user)
      if request.get?
        render "finish"
      else
        render json: { status: "reload" };
      end
    end
  end
  
  private
  
  def calculate_streak
    if current_user.earned_points == 0
      @streak = 0
    else
      @streak = session[:ssf].to_i
      @last_task = CompletedTask.joins(:task).where("section_id = ?", @section.id).last
      if @last_task.nil? || @last_task.status_id == Answer::INCORRECT
        @streak = 0
      else
        @streak = @streak + 1
      end
    end
    session[:ssf] = @streak 
  end
    
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