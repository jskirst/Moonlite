class TasksController < ApplicationController
  before_filter :authenticate
  before_filter :load_resource, except: [:create]
  before_filter :authorize_resource, except: [:vote, :report, :create]
  
  respond_to :json, :html
  
  def create
    @section = Section.find(params[:task][:section_id])
    raise "Access Denied" unless can_add_tasks(@section.path)
    
    @task = @section.tasks.new(params[:task])
    @task.creator_id = current_user.id
    @task.answer_content = gather_answers(params[:task])
    if @task.save
      unless params[:stored_resource_id].blank?
        sr = StoredResource.find(params[:stored_resource_id])
        raise "FATAL: STEALING RESOURCE" if sr.owner_id
        sr.owner_id = @task.id
        sr.owner_type = @task.class.to_s
        sr.save
      end
      current_user.award_points(@task, 50)
      if @task.source == "launchpad"
        render json: { status: "success", question_link: take_section_url(@section, task_id: @task.id) }
      else
        render partial: "task", locals: { task: @task }
      end
    else
      respond_to {|f| f.json { render :json => { :errors => @task.errors.full_messages } } }
    end
  end
  
  def edit
    @stored_resource = @task.stored_resources.first
    @answers = @task.answers
    respond_to {|f| f.html { render :partial => "edit_task_form" } }
  end
    
  def update
    errors = []
    unless @task.question == params[:task][:question]
      @task.question = params[:task][:question]
      errors = @task.errors.full_messages unless @task.save
    end
    errors += @task.update_answers(params[:task])
    
    if errors.empty?
      respond_to do |f|
        f.html { render :partial => "task", :locals => {:task => @task} }
        f.json { render :json => @task }
      end
    else
      respond_to { |f| f.json { render :json => { :errors => errors } } }
    end
  end
  
  def destroy
    if @task.destroy
      respond_to { |f| f.json { render :json => { :success => "Question deleted." } } }
    else
      respond_to { |f| f.json { render :json => { :errors => "Question could not be deleted." } } }
    end
  end
  
  def vote
    @submission = @task.submitted_answers.find(params[:sa_id])
    if @vote = current_user.votes.find_by_submitted_answer_id(@submission.id)
      if @vote.destroy && @submission.subtract_vote(current_user)
        render json: @vote.to_json
      else
       render json: { errors: "Error removing your vote." }
      end
    else
      if @vote = @submission.add_vote(current_user)
        path = @submission.path
        content = "#{current_user.name} voted for your submission."
        link = submission_details_path(path, @submission.id)
        log_event(@submission.user, link, current_user.profile_pic, content)
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
  
  private
    def load_resource
      @task = Task.find(params[:id])
    end
  
    def authorize_resource
      raise "Access Denied" unless can_edit_path(@task.path)
    end
    
    def gather_answers(task)
      params[:task][:answer1] = params[:task][:fibanswer1] if params[:task][:answer_type] == "1"
      answers = []
      answers << { content: task[:answer1], is_correct: true } if task[:answer1]
      answers << { content: task[:answer2], is_correct: false } if task[:answer2]
      answers << { content: task[:answer3], is_correct: false } if task[:answer3]
      answers << { content: task[:answer4], is_correct: false } if task[:answer4]
      return answers
    end
end