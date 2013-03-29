class SectionsController < ApplicationController
  before_filter :authenticate, except: [:continue, :complete]
  before_filter :load_resource
  before_filter :authorize_edit, only: [:new, :create, :edit, :update, :publish, :unpublish, :destroy, :confirm_delete]
  before_filter :disable_navbar, except: [:new, :create]  
  
  def new
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
        redirect_to edit_path_path(@path)
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
        .select("section_id, status_id, question, tasks.id, points_awarded, answer_type, answer_sub_type")
        .where("tasks.section_id = ? and tasks.locked_at is ?", @current_section.id, nil)
      @core_tasks = @tasks.select { |t| t.answer_type == Task::MULTIPLE }
      @challenge_tasks = @tasks.select { |t| t.answer_type == Task::CREATIVE }
      @achievement_tasks = @tasks.select { |t| t.answer_type == Task::CHECKIN }
      @display_type = params[:type] || 2
      render partial: "launchpad"
    else
      render json: { status: "locked" }
    end
  end
  
  def take
    @hide_background = true
    @task = @section.tasks.find(params[:task_id])
    raise "Access Denied: Not a challenge." unless @task.creative_response? or @task.task?
    raise "Access Denied: Task is currently locked." if @task.locked_at
    @path = @section.path
    @stored_resource = @task.stored_resources.first
    
    @completed_task = @enrollment.completed_tasks.find_by_task_id(@task.id)
    unless @completed_task
      @completed_task = current_user.completed_tasks.new(task_id: @task.id)
      @completed_task.status_id = Answer::INCOMPLETE
      @completed_task.enrollment_id = @enrollment.id
      @completed_task.session_id = params[:session_id]
      @completed_task.save!
      @submitted_answer = SubmittedAnswer.new
    else
      @submitted_answer = @completed_task.submitted_answer || SubmittedAnswer.new
    end
  end
  
  def took
    @task = @section.tasks.find(params[:task_id])
    raise "Only CRs can be taken." unless @task.creative_response? or @task.task?
    raise "Access Denied: Task is currently locked." if @task.locked_at
    
    completed_task = @enrollment.completed_tasks.find_by_task_id(@task.id)
    unless completed_task
      completed_task = current_user.completed_tasks.new(task_id: @task.id)
      completed_task.status_id = Answer::INCOMPLETE
      completed_task.enrollment_id = @enrollment.id
      completed_task.save!
    end
    
    if completed_task.incomplete? and not (params[:mode] == "preview" or params[:mode] == "draft")
      completed_task.status_id = Answer::CORRECT
      completed_task.points_awarded = CompletedTask::CORRECT_POINTS
      completed_task.award_points = true
      completed_task.save!
    end
    
    sa = completed_task.submitted_answer ||  @task.submitted_answers.new
    sa.content = params[:content] unless params[:content].blank?
    sa.url = params[:url] unless params[:url].blank?
    sa.image_url = params[:image_url] unless params[:image_url].blank?
    sa.title = params[:title] unless params[:title].blank?
    sa.description = params[:description] unless params[:description].blank?
    sa.caption = params[:caption] unless params[:caption].blank?
    sa.site_name = params[:site_name] unless params[:site_name].blank?
    
    unless sa.save
      redirect_to challenge_path(@section.path.permalink), alert: "You must supply a valid answer."
      return
    else
      completed_task.submitted_answer_id = sa.id
      completed_task.save!
      
      unless params[:stored_resource_id].blank?
        sr = assign_resource(sa, params[:stored_resource_id])
        sa.update_attribute(:image_url, sr.obj.url)
      end
    
      if params[:mode] == "draft" or params[:mode] == "preview"
        redirect_to take_section_path(@section, task_id: @task.id, m: params[:mode])
      else
        redirect_to challenge_path(@section.path.permalink, c: true, type: @task.answer_type)
      end
    end
  end
  
  def complete
    task_id = params[:task_id]
    points = params[:points_remaining].to_i
    supplied_answer = Answer.find(params[:answer])
    correct_answer = supplied_answer.is_correct ? supplied_answer : Answer.where(task_id: task_id, is_correct: true).first
    
    if current_user
      session_id = params[:session_id]
      completed_task = current_user.completed_tasks.find_by_task_id(task_id)
      if completed_task.nil?
        completed_task = current_user.completed_tasks.create!(task_id: task_id, status_id: Answer::INCOMPLETE, session_id: session_id)
      elsif completed_task.status_id != Answer::INCOMPLETE
        raise "Already answered"
      elsif completed_task.created_at <= 60.seconds.ago and points > 0
        raise "Out of time"
      end
      
      completed_task.enrollment_id = @enrollment.id
      completed_task.answer_id = supplied_answer.id
      if supplied_answer == correct_answer
        completed_task.status_id = Answer::CORRECT
        completed_task.points_awarded = points
        completed_task.award_points = true
        session[:ssf] = session[:ssf].to_i + 1
      else
        completed_task.status_id = Answer::INCORRECT
        completed_task.points_awarded = 0
        session[:ssf] = 0
      end
      completed_task.save!
      Answer.increment_counter(:answer_count, supplied_answer.id)
    end
    render json: { correct_answer: correct_answer.id, supplied_answer: supplied_answer.id }
  end
    
  def continue
    create_or_sign_in unless current_user
    @enrollment = current_user.enroll!(@path) unless @enrollment
    
    @session_id = params[:session_id] || Time.now().to_i + current_user.id
    current_session = current_user.completed_tasks.where(session_id: @session_id)
    @question_count = current_session.count
    @session_total = @section.remaining_tasks(current_user, Task::MULTIPLE) + @question_count
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
      @rank = @enrollment.rank
      if @rank > @enrollment.highest_rank
        @enrollment.update_attribute(:highest_rank, @rank)
      end
      @completed_task = current_user.completed_tasks.create!(task_id: @task.id, status_id: Answer::INCOMPLETE, session_id: @session_id)
      @answers = @task.answers.to_a.shuffle
      @stored_resource = @task.stored_resources.first
      page = "continue"
    else
      if @task = @section.next_task(current_user, false, Task::CREATIVE)
        redirect_to take_bonus_section_path(@section, @task.id, @session_id) and return
      else
        @available_crs = @section.tasks.where("answer_type = ?", Task::CREATIVE).size
        @unlocked_sections = @path.sections.where("points_to_unlock <= ?", @enrollment.total_points).size 
        social_tags(@path.name, @path.picture, @path.description)
        page = "finish"
      end
    end
    session[:ssf] = @streak
    @hide_background = true
    if request.xhr?
      render file: "sections/#{page}", layout: false
    else
      render page
    end
  end
  
  private
  
  def disable_navbar
    @show_nav_bar = false
    @show_footer = false
  end
  
  def load_resource
    if params[:id]
      @section = Section.find(params[:id])
      @path = @section.path
    elsif params[:path_id] || params[:section][:path_id]
      @path = Path.find(params[:path_id] || params[:section][:path_id])
      @section = @path.sections.new
    else
      raise "FATAL: attempt to access unknown path."
    end
    @enrollment = current_user.enrollments.find_by_path_id(@path.id) if current_user
  end
  
  def authorize_edit
    raise "Edit Access Denied" unless can_edit_path(@path)
  end
end