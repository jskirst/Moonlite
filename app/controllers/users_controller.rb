class UsersController < ApplicationController
  before_filter :authenticate, except: [:show]
  before_filter :load_resource, except: [:retract]
  before_filter :authorize_resource, except: [:show, :retract]
  
  def show
    @page = params[:page].to_i
    offset = @page * 30
    if params[:task]
      all_responses = @user.completed_tasks.joins(:submitted_answer, :task)
      @newsfeed_items = [all_responses.find_by_task_id(params[:task])]
    elsif params[:order] && params[:order] == "votes"
      all_responses = @user.completed_tasks.offset(offset).limit(30).joins(:submitted_answer, :task).where("answer_type = ?", Task::CREATIVE).order("total_votes DESC")
    else
      all_responses = @user.completed_tasks.offset(offset).limit(30).joins(:submitted_answer, :task).where("answer_type = ?", Task::CREATIVE).order("completed_tasks.created_at DESC")
    end  
    @newsfeed_items = all_responses if @newsfeed_items.nil?
    
    @completed_tasks = current_user.completed_tasks
      .joins(:task, :path)
      .select("tasks.question, tasks.answer_type, paths.name")
      .where("tasks.answer_type = ?", Task::CHECKIN)
    @completed_tasks = @completed_tasks.group_by(&:name)
    
    @enrolled_personas = @user.personas
    @user_personas = @user.user_personas.includes(:persona)
    
    @creative_tasks = all_responses.collect { |item| item.task }
    @enrollments = @user.enrollments.includes(:path).where("total_points > ?", 100).sort { |a,b| b.total_points <=> a.total_points }
    
    @votes = current_user.nil? ? [] : current_user.votes.to_a.collect {|v| v.submitted_answer_id } 
    @title = @user.name
    @more_available = @newsfeed_items.size == 30
    @more_available_url = profile_path(@user.username, page: @page+1)
    if request.xhr?
      render partial: "shared/newsfeed", locals: { newsfeed_items: @newsfeed_items }
    else
      render "users/show"
    end
  end
  
  def edit
    @title = "Settings"
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile successfully updated."
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    @user.destroy
    redirect_to root_url
  end
  
  def retract
    @submitted_answer = CompletedTask.find(params[:submission_id])
    raise "Access Denied" unless @submitted_answer.user == current_user
    @submitted_answer.destroy
    render json: { status: "success" }
  end
  
  private
    def load_resource
      @user = User.find_by_username(params[:username]) if params[:username]
      @user = User.find_by_id(params[:id]) if params[:id]
      redirect_to root_path and return if @user.nil?
    end
    
    def authorize_resource
      raise "Access Denied" unless @user == current_user
    end
  
    def user_only
      redirect_to root_path unless current_user.id == @user.id
    end
end
