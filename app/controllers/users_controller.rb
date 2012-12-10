class UsersController < ApplicationController
  before_filter :authenticate, except: [:request_send, :send_reset, :request_reset, :reset_password, :show]
  before_filter :find_by_id, except: [:show, :request_reset, :request_send, :reset_password]
  before_filter :has_access?, only: [:lock, :edit_role, :update_role]
  before_filter :user_only,  only: [:edit, :update, :destroy]
  
  def show
    @user = User.find_by_username(params[:username]) if params[:username]
    @user = User.find_by_id(params[:id]) if params[:id]
    
    @page = params[:page].to_i
    offset = @page * 30
    if params[:task]
      all_responses = @user.completed_tasks.joins(:submitted_answer)
      @newsfeed_items = [all_responses.find_by_task_id(params[:task])]
    elsif params[:order] && params[:order] == "votes"
      all_responses = @user.completed_tasks.offset(offset).limit(30).joins(:submitted_answer).all(order: "total_votes DESC")
    else
      all_responses = @user.completed_tasks.offset(offset).limit(30).joins(:submitted_answer).all(order: "completed_tasks.created_at DESC")
    end  
    @newsfeed_items = all_responses if @newsfeed_items.nil?
    
    @creative_tasks = all_responses.collect { |item| item.task }
    @enrollments = @user.enrollments.includes(:path).sort { |a,b| b.level <=> a.level }
    @enrolled_personas = @user.personas
    @votes = current_user.nil? ? [] : current_user.votes.to_a.collect {|v| v.submitted_answer_id } 
    @title = @user.name
    @more_available = @newsfeed_items.size == 30
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
  
  def edit_role
    @user_roles = current_company.user_roles
  end
  
  def update_role
    @user_role = current_company.user_roles.find(params[:user][:user_role_id])
    @user.user_role_id = @user_role.id
    if @user.save
      redirect_to current_user.company, flash: { success: "User role changed successfully." }
    else
      raise "Runtime error" + current_user.to_yaml + @user.to_yaml
    end
  end
  
  def destroy
    @user.destroy
    redirect_to root_url
  end
  
  private
    def find_by_id
      @user = User.find_by_id(params[:id]) if params[:id]
    end
    
    def has_access?
      raise "ACCESS DENIED" unless @enable_administration
    end
  
    def user_only
      redirect_to root_path unless current_user.id == @user.id
    end
end
