class TasksController < ApplicationController
  before_filter :authenticate
  before_filter :has_access?
  before_filter :get_task_from_id, :only => [:edit, :update, :destroy, :resolve, :vote, :add_stored_resource]
  before_filter :can_edit?, :only => [:edit, :update, :destroy, :resolve]
  
  respond_to :json, :html
  
  def new
    @section = Section.find(@section_id)
    unless can_edit_path(@section.path)
      redirect_to root_path, alert: "You cannot add tasks to this path."
      return
    end    
    @task = Task.new
    @form_title = "New Question"
    render "tasks/task_form"
  end
  
  def create
    @section = Section.find(params[:task][:section_id])
    unless can_edit_path(@section.path)
      respond_with({ :error => "No access." }) and return
    end
    
    @task = @section.tasks.new(params[:task])
    @task.answer_content = gather_answers(params[:task])
    if @task.save
      respond_to do |f|
        f.html { render :partial => "task", :locals => {:task => @task } }
        f.json { render :json => @task }
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
  
  def suggest
    @phrase = Phrase.search(params[:phrase].downcase)
    @associated_phrases = []
    unless @phrase.nil?
      @associated_phrases = @phrase.associated_phrases
      @original_content = @phrase.original_content
    else
      @original_content = ""
    end
    respond_to { |f| f.json }
  end
  
  def destroy
    if @task.destroy
      respond_to { |f| f.json { render :json => { :success => "Question deleted." } } }
    else
      respond_to { |f| f.json { render :json => { :errors => "Question could not be deleted." } } }
    end
  end
  
  def resolve
    @completed_task = @task.completed_tasks.find(params[:completed_task][:id])
    @page = params[:page] || 1
    if params[:commit] == "Delete"
      @completed_task.submitted_answer.destroy
      flash[:success] = "Submission deleted."
    else
      unless points = (params[:completed_task][:points]).to_i
        flash[:error] = "No points argument found."
      else
        if points > 0
          @completed_task.user.award_points(@completed_task.task, points)
          @completed_task.status_id = 1
        else
          @completed_task.status_id = 0
        end
        @completed_task.points_awarded = points
        if @completed_task.save
          flash[:success] = "Resolved."
        else
          raise "Error, could save resolution."
        end
      end
    end
    redirect_to dashboard_path_path(@task.path, :page => @page, :anchor => "unresolved_tasks_list")        
  end
  
  def vote
    @submission = @task.submitted_answers.find(params[:sa_id])
    unless @submission
      flash[:error] = "Submitted answer does not belong to this task."
    else
      if @vote = current_user.votes.find_by_submitted_answer_id(@submission.id)
        if @vote.destroy && @submission.subtract_vote(current_user)
          respond_to {|format| format.json { render :json => @vote.to_json } }
        else
          respond_to {|format| format.json { render :json => { :errors => "Error removing your vote." } } }
        end
      else
        @other_task_votes = current_user.votes.joins(:submitted_answer).where("submitted_answers.task_id = ?", @task.id).count
        if @other_task_votes < 3
          if @vote = @submission.add_vote(current_user)
            respond_to {|format| format.json { render :json => @vote.to_json } }
          else
            respond_to {|format| format.json { render :json => { :errors => "Uknown error."} } }
          end
        else
          respond_to {|format| format.json { render :json => { :errors => "You have no more votes to spend for this question."} } }
        end
      end
    end
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
    def get_task_from_id
      @task = Task.find(params[:id])
    end
    
    def has_access?
      unless @enable_user_creation
        flash[:error] = "You do not have the ability to edit this task."
        redirect_to root_path
      end
    end
  
    def can_edit?
      unless can_edit_path(@task.path)
        flash[:error] = "You do not have access to this Path. Please contact your administrator to gain access."
        redirect_to root_path
      end
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