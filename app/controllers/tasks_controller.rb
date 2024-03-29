class TasksController < ApplicationController
  include EventsHelper
  before_filter :authenticate, except: [:raw, :complete]
  before_filter :load_resource, except: [:create, :raw]
  before_filter :authorize_resource, except: [:vote, :report, :create, :raw, :complete, :took]
  
  respond_to :json, :html
  
  def create
    @section = Section.find(params[:task][:section_id])
    path = @section.path
    raise "Access Denied" unless path.can_add_tasks?(current_user)
    
    @task = @section.tasks.new(params[:task])
    @task.creator_id = current_user.id
    @task.answer_content = gather_answers(params[:task])
    @task.reviewed_at = Time.now() if path.group_id or current_user.enable_administration?
    @task.path_id = path.id
    
    if @enable_administration
      if params[:task][:professional].present?
        @task.professional_at = params[:task][:professional].to_i == 1 ? Time.now : nil
      end
    end
    
    if @task.save
      if parent = @task.parent
        parent.update_attribute(:archived_at, Time.now)
        if parent.stored_resources.any?
          parent.stored_resources.each do |sr|
            new_sr = sr.dup
            new_sr.obj = sr.obj
            new_sr.owner_id = @task.id
            new_sr.save
          end
        end
      end

      unless params[:stored_resource_id].blank?
        sr = StoredResource.find(params[:stored_resource_id])
        raise "FATAL: STEALING RESOURCE" if sr.owner_id
        sr.owner_id = @task.id
        sr.owner_type = @task.class.to_s
        sr.save
      end

      if @task.creative? and path.published? and path.approved? and path.group_id.nil?
        # UserEvent.create! do |ue|
        #   ue.user = current_user
        #   ue.path = path
        #   ue.image_link = UserEvent.user_event_icon(:new_question)
        #   ue.link = take_section_path(@task.section_id, task_id: @task.id)
        #   ue.action_text = "Take #{current_user.name.split.first}'s new question."
        #   ue.content = "#{current_user.name} added a new question to the #{path.name} Challenge."
        # end
      end

      if @task.source == "launchpad"
        render json: { status: "success", question_link: take_section_url(@section, task_id: @task.id) }
      else
        render partial: "task", locals: { task: @task, move: false }
      end
    else
      respond_to {|f| f.json { render :json => { :error => @task.errors.full_messages.join(". ") }, status: :bad_request } }
    end
  end
  
  def edit
    task = @task.dup
    task.parent_id = @task.id
    @path = @task.path
    @sections = @path.sections.order("position ASC")
    @topics = @path.topics
    answers = @task.answers.order("is_correct DESC").to_a.collect(&:dup)
    if task.multiple_choice?
      (4 - answers.size).times { answers << task.answers.new(is_correct: false) }
    elsif (task.exact? or task.creative?) and answers.empty?
      answers << task.answers.new(is_correct: true)
    end
    respond_to {|f| f.html { render :partial => "form", locals: { task: task, answers: answers } } }
  end
    
  def update
    sid = params[:task].delete(:section_id).to_i
    
    sr_id = params.delete(:stored_resource_id)
    unless sr_id.blank?
      sr = StoredResource.find(sr_id)
      raise "FATAL: STEALING RESOURCE" if sr.owner_id
      sr.owner_id = @task.id
      sr.owner_type = @task.class.to_s
      sr.save
    end
    
    if @enable_administration
      if params[:task][:professional].present?
        @task.professional_at = params[:task][:professional].to_i == 1 ? Time.now : nil
      end
    end

    @task.update_attributes(params[:task])

    errors = @task.errors.full_messages
    errors += @task.update_answers(params[:task])
    
    if sid != @task.section_id
      sids = @task.path.sections.pluck(:id)
      if sids.include?(sid)
        @task.section_id = sid
        @task.save!
        move = sid
      else
        raise "Access Denied: Invalid section (#{sid}) - (#{sids})" 
      end
    else
      move = false
    end
    
    if errors.empty?
      respond_to do |f|
        f.html { render :partial => "task", :locals => { task: @task, move: move } }
        f.json { render :json => @task }
      end
    else
      respond_to { |f| f.json { render :json => { :errors => errors } } }
    end
  end
  
  def destroy
    if @enable_administration || @task.creator == current_user
      if @task.destroy
        respond_to { |f| f.json { render :json => { :success => "Question deleted." } } }
      else
        respond_to { |f| f.json { render :json => { :errors => "Question could not be deleted." } } }
      end
    else
      raise "Access Denied"
    end
  end
  
  def complete
    create_or_sign_in unless current_user
    enrollment = current_user.enrollments.where(path_id: @path.id).first

    completed_task = CompletedTask.find_or_create(current_user, @task, enrollment, params[:session_id])
    points = params[:points_remaining].to_i
    completed_task.complete_core_task!(params[:answer], points)
    completed_task.reload
    if completed_task.correct?
      session[:ssf] = session[:ssf].to_i + 1
      new_difficulty = current_path_difficulty(@path) + 0.07
      current_path_difficulty(@path, new_difficulty)
      if points > 0
        check_for_and_create_events(points, completed_task.enrollment, current_user)
      end
    else
      session[:ssf] = 0
      new_difficulty = current_path_difficulty(@path) - 0.07
      current_path_difficulty(@path, new_difficulty)
    end
    
    render json: { 
      correct_answer: completed_task.correct_answer, 
      answer: completed_task.answer, 
      correct: completed_task.correct?,
      difficulty: current_path_difficulty(@path)
    }
  end
  
  def took
    task = Task.cached_find(params[:id])
    enrollment = current_user.enrollments.where(path_id: @path.id)
    raise "Access Denied: Task is currently locked." if task.locked_at
    completed_task = CompletedTask.find_or_create(current_user, task, enrollment, params[:session_id])
    if task.time_limit and task.time_limit >= 120
      if (completed_task.created_at + (task.time_limit + 10).seconds) < Time.now()
        raise "Time expired"
      end
    end
    
    publish = !(["draft", "preview"].include?(params[:mode]))
    submitted_answer = completed_task.submitted_answer ||  task.submitted_answers.new
    submitted_answer.submit!(completed_task, current_user, publish, params)
    
    if publish
      redirect_to params[:submit_redirect_url]
    else
      redirect_to params[:draft_redirect_url]
    end
  end
  
  def archive
    @task.update_attribute(:archived_at, Time.now())
    render json: { status: :success }
  end
  
  def vote
    @submission = @task.submitted_answers.find(params[:sa_id])
    if @vote = current_user.votes.find_by_owner_id(@submission.id)
      if @submission.subtract_vote(current_user, @vote)
        render json: @vote.to_json
      else
       render json: { errors: "Error removing your vote." }
      end
    else
      if @vote = @submission.add_vote(current_user)
        path = @submission.path
        link = submission_details_path(path.permalink, @submission.id)
        UserEvent.log_event(@submission.user, "#{current_user.name} voted for your submission.", current_user, link, current_user.picture)
        render json: @vote.to_json
      else
        render json: { errors: "Uknown error."}
      end
    end
  end
  
  def report
    issue = current_user.task_issues.new(task_id: @task.id, issue_type: params[:task_issue][:issue_type])
    if issue.save
      flash[:success] = "Thank you for reporting this question. Once two or more users have reported the same issue, the question will be removed. Thanks for your help keeping MetaBright at its best!"
    else
      flash[:error] = "We're sorry, your issue could not be reported. You may have tried to create another issue report for the same question."  
    end
    if params[:redirect_url]
      redirect_to params[:redirect_url]
    else
      redirect_to continue_path_path(@task.path.permalink)
    end
  end
  
  def add_stored_resource
    if request.get?
      @stored_resource = @task.stored_resources.new
    else
      @stored_resource = @task.stored_resources.new(params)
      if @stored_resource.save
        redirect_to edit_path_path(@task.path), success: "Image added."
      else
        flash[:error] = "Error occurred, could not add your image."
      end
    end
  end
    
  def raw
    begin
      render text: SubmittedAnswer.cached_find(params[:id]).content.gsub("<body>", "<body><script>alert=null;</script>").gsub("<body>", "<body><script>alert=null;</script>")
    rescue
      render text: "<html><body></body></html>"
    end
  end
  
  private
    def load_resource
      @task = Task.cached_find(params[:id])
      @path = @task.path
    end
  
    def authorize_resource
      raise "Access Denied" unless @enable_administration or can_edit_path(@task.path)
    end
end