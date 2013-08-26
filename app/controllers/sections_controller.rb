class SectionsController < ApplicationController
  before_filter :authenticate, except: [:continue, :complete]
  before_filter :load_resource, except: [:subregion_options]
  before_filter :authorize_edit, only: [:new, :create, :edit, :update, :publish, :unpublish, :destroy, :confirm_delete]
  before_filter :disable_navbar, except: [:new, :create]  
  
  def new
    @hide_background = true
    @path = Path.find(params[:path_id])
    if can_edit_path(@path)
      @section = @path.sections.new
      @title = "New section"
    else
      redirect_to root_path
    end
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
        redirect_to edit_path_path(@path.permalink)
      else
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
      @tasks = @section.tasks.all(order: "id DESC")
      @display = (@tasks.empty?)
      respond_to do |f|
        f.html { render partial: "edit_tasks", locals: { display_new_task_form: @display, task: @task, tasks: @tasks, section: @section } }
      end
    elsif params[:m] == "settings"
      respond_to do |f|
        f.html { render partial: "edit_settings", locals: { section: @section } }
      end
    elsif params[:m] == "content"
      @stored_resources = @section.stored_resources
      respond_to do |f|
        f.html { render partial: "edit_content", locals: { section: @section, stored_resources: @stored_resources } }
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
    @section.published_at = Time.now
    if @section.save
      flash[:success] = "#{@section.name} has been successfully published. Note that if you have not already, you will still need to publish the #{name_for_paths.downcase} as a whole before it will be visible to the community."
    else
      flash[:error] = "There was an error publishing."
    end
    redirect_to edit_path_path(@section.path)
  end
  
  def unpublish
    other_sections = @section.path.sections.where("published_at is not ? and id != ?", nil, @section.id)
    if other_sections.size < 1
      flash[:error] = "You cannot unpublish a section if it is the only one. You must unpublish the whole Challenge."
    else
      @section.published_at = Time.now
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
    if @section.unlocked?(current_user)
      @tasks = Task.joins("LEFT OUTER JOIN completed_tasks on tasks.id = completed_tasks.task_id and completed_tasks.user_id = #{current_user.id}")
        .select("section_id, status_id, question, tasks.id, points_awarded, answer_type, answer_sub_type, completed_tasks.submitted_answer_id")
        .where("tasks.section_id = ? and tasks.locked_at is ? and tasks.reviewed_at is not ?", @current_section.id, nil, nil)
      @core_tasks = @tasks.select { |t| t.core? }
      @challenge_tasks = @tasks.select { |t| t.creative? }
      @achievement_tasks = @tasks.select { |t| t.task? }
      @display_type = params[:type] || 2
      render partial: "launchpad"
    else
      render json: { status: "locked" }
    end
  end
  
  def take
    @task = Task.cached_find(params[:task_id])
    raise "Access Denied: Task is currently locked." if @task.locked_at
    @session_id = params[:session_id]
    
    @completed_task = CompletedTask.find_or_create(current_user.id, @task.id, params[:session_id])
    @submitted_answer = @completed_task.submitted_answer_id ? @completed_task.submitted_answer : SubmittedAnswer.new
    
    @stored_resource = @task.stored_resources.first
    @hide_background = true
  end
  
  def took
    task = Task.cached_find(params[:task_id])
    raise "Access Denied: Task is currently locked." if task.locked_at
    completed_task = CompletedTask.find_or_create(current_user.id, task.id, params[:session_id])
    
    publish = !(["draft", "preview"].include?(params[:mode]))
    submitted_answer = completed_task.submitted_answer ||  task.submitted_answers.new
    submitted_answer.submit!(completed_task, current_user, publish, params)
    
    if publish
      if completed_task.session_id
        redirect_to finish_section_path(@section, completed_task.session_id) and return
      else
        redirect_to challenge_path(@section.path.permalink, c: true, type: task.answer_type)
      end
    else
      redirect_to take_section_path(@section, task_id: task.id, m: params[:mode])
    end
  end
    
  def continue
    create_or_sign_in unless current_user
    @enrollment = current_user.enroll!(@path) unless @enrollment
    
    @session_id = params[:session_id] || Time.now().to_i + current_user.id
    current_session = current_user.completed_tasks.where(session_id: @session_id)
    @question_count = current_session.count
    @session_total = @section.remaining_tasks(current_user, [Task::MULTIPLE, Task::EXACT]) + @question_count
    @session_total = 7 if @session_total > 7
     
    if @question_count <= 6
      @task = @section.next_task(current_user)
    end
    
    if @task
      @question_count += 1
      @streak = session[:ssf].to_i
      if @streak > @enrollment.longest_streak
        @enrollment.update_attribute(:longest_streak, @streak)
      end
      @completed_task = current_user.completed_tasks.create!(enrollment_id: @enrollment.id, task_id: @task.id, status_id: Answer::INCOMPLETE, session_id: @session_id)
      @answers = Answer.cached_find_by_task_id(@task.id).shuffle
      @stored_resource = @task.stored_resources.first
      page = "continue"
    else
      if @task = @section.next_task(current_user, false, Task::CREATIVE, Task::TEXT)
        redirect_to boss_section_path(@section, @task.id, @session_id)
        return
      else
        if @question_count == 0
          redirect_to challenge_path(@path.permalink, c: true, p: @section.points_earned(current_user))
        else
          redirect_to finish_section_path(@section, @session_id)
        end
        return
      end
    end
    session[:ssf] = @streak
    @start_countdown = true
    @show_stats = true
    @next_link = continue_section_path(@task.section_id, @session_id)
    if request.xhr?
      render file: "tasks/#{page}", layout: false
    else
      @hide_background = true
      render "tasks/#{page}"
    end
  end
  
  def boss
    if current_user.completed_tasks.where(session_id: params[:session_id]).count == 0
      redirect_to challenge_path(@path.permalink, c: true)
    else
      @hide_background = true
      render "pre_boss"
    end
  end
  
  def finish
    @hide_background = true
    @session_id = params[:session_id]
    if params[:s].blank? and current_user.seen_opportunities
      completed_tasks = current_user.completed_tasks
        .where(session_id: @session_id)
        .joins(:task)
        .joins("LEFT JOIN topics on topics.id=tasks.topic_id")
        .select("topics.name, completed_tasks.*")
      @performance = PerformanceStatistics.new(completed_tasks, @enrollment)
      @total_session_points = completed_tasks.sum(:points_awarded)
      render "finish"
    elsif params[:s].blank?
      @sample = @enrollment.total_points < 600
      @total_session_points = current_user.completed_tasks.where(session_id: @session_id).sum(:points_awarded)
      render "finish"
    else
      step = params[:s].to_i
      current_user.update_attributes(seen_opportunities: true)
      
      if params[:user]
        if !current_user.update_attributes(params[:user])
          @error = current_user.errors.full_messages.first
          render "register#{step - 1}"
          return
        end
      end
      
      if step == 3
        sign_in(current_user)
        clear_return_back_to
        render "register3"
      else
        if current_user.guest_user?
          set_return_back_to(finish_section_url(@section, @session_id, s: 3))
        elsif step == 2
          clear_return_back_to
          render "register3" and return
        end
        render "register#{step}"
      end
    end
  end
  
  def subregion_options
    render partial: 'shared/subregion_select', locals: { form: nil }
  end
  
  private
  
  def disable_navbar
    @show_nav_bar = false
    @show_footer = false
  end
  
  def load_resource
    if params[:id]
      @section = Section.cached_find(params[:id])
      @path = Path.cached_find_by_id(@section.path_id)
    elsif params[:path_id] || params[:section][:path_id]
      @path = Path.cached_find_by_id(params[:path_id] || params[:section][:path_id])
      @section = @path.sections.new
    else
      raise "FATAL: attempt to access unknown path."
    end
    unless request.xhr?
      @path_custom_style = @path.custom_style
    end
    @enrollment = current_user.enrollments.find_by_path_id(@path.id) if current_user
  end
  
  def authorize_edit
    raise "Edit Access Denied" unless can_edit_path(@path)
  end
end