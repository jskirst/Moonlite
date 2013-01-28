class UsersController < ApplicationController
  before_filter :authenticate
  before_filter :load_resource, except: [:retract]
  before_filter :authorize_resource, except: [:retract]
  
  def edit
    @title = "Settings"
  end
  
  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile successfully updated."
      redirect_to profile_path(@user.username)
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
      @user = User.find_by_username(params[:id])
      @user = User.find_by_id(params[:id]) unless @user
      redirect_to root_path and return if @user.nil?
    end
    
    def authorize_resource
      raise "Access Denied" unless @user == current_user
    end
  
    def user_only
      redirect_to root_path unless current_user.id == @user.id
    end
end
