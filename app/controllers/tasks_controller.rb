class TasksController < ApplicationController
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
    @task.reviewed_at = Time.now() if path.group_id
    @task.path_id = path.id
    
    if @task.save
      unless params[:stored_resource_id].blank?
        sr = StoredResource.find(params[:stored_resource_id])
        raise "FATAL: STEALING RESOURCE" if sr.owner_id
        sr.owner_id = @task.id
        sr.owner_type = @task.class.to_s
        sr.save
      end
      if @task.source == "launchpad"
        render json: { status: "success", question_link: take_section_url(@section, task_id: @task.id) }
      else
        render partial: "task", locals: { task: @task, move: false }
      end
    else
      respond_to {|f| f.json { render :json => { :errors => @task.errors.full_messages.join(". ") } } }
    end
  end
  
  def edit
    task = @task
    @path = @task.path
    @sections = @path.sections.order("position ASC")
    @topics = @path.topics
    answers = task.answers.order("is_correct DESC").to_a
    if task.multiple_choice?
      (4 - answers.size).times { answers << task.answers.new(is_correct: false) }
    elsif (task.exact? or task.creative?) and answers.empty?
      answers << task.answers.new(is_correct: true)
    end
    respond_to {|f| f.html { render :partial => "form", locals: { task: task, answers: answers } } }
  end
    
  def update
    sid = params[:task].delete(:section_id).to_i
    
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
    
    completed_task = CompletedTask.find_or_create(current_user.id, @task.id, params[:session_id])
    
    # TODO: Completed task does not specify that it must be from this enrollment
    completed_task.complete_core_task!(params[:answer], params[:points_remaining])
    session[:ssf] = completed_task.correct? ? (session[:ssf].to_i + 1) : 0
    
    render json: { 
      correct_answer: completed_task.correct_answer, 
      answer: completed_task.answer, 
      correct: completed_task.correct? 
    }
  end
  
  def took
    task = Task.cached_find(params[:id])
    raise "Access Denied: Task is currently locked." if task.locked_at
    completed_task = CompletedTask.find_or_create(current_user.id, task.id, params[:session_id])
    if task.time_limit
      if (completed_task.created_at + (task.time_limit + 10).seconds) < Time.now()
        raise "Time expired"
      end
    end
    
    publish = !(["draft", "preview"].include?(params[:mode]))
    submitted_answer = completed_task.submitted_answer ||  task.submitted_answers.new
    submitted_answer.submit!(completed_task, current_user, publish, params)
    
    if publish
      redirect_to params[:submit_redirect_uri]
    else
      redirect_to params[:draft_redirect_uri]
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
      flash[:alert] = "Thank you for reporting this question. Once two or more users have reported the same issue, the question will be removed. Thanks for your help keeping MetaBright at its best!"
    else
      flash[:alert] = "We're sorry, your issue could not be reported. You may have tried to create another issue report for the same question."  
    end
    redirect_to challenge_path(@task.path.permalink)
  end
  
  def add_stored_resource
    unless params[:commit]
      @stored_resource = @task.stored_resources.new
    else
      @stored_resource = @task.stored_resources.new(params)
      if @stored_resource.save
        redirect_to edit_path_path(@task.path), notice: "Image added."
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
    end
  
    def authorize_resource
      raise "Access Denied" unless @enable_administration or can_edit_path(@task.path)
    end
    
    def gather_answers(task)
      answers = []
      answers << { content: task[:exact1], is_correct: true } unless task[:exact1].blank?
      answers << { content: task[:answer_new_1], is_correct: true } unless task[:answer_new_1].blank?
      answers << { content: task[:answer_new_2], is_correct: false } unless task[:answer_new_2].blank?
      answers << { content: task[:answer_new_3], is_correct: false } unless task[:answer_new_3].blank?
      answers << { content: task[:answer_new_4], is_correct: false } unless task[:answer_new_4].blank?
      return answers
    end
end