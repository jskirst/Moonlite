class UsersController < ApplicationController
  include NewsfeedHelper
  
  before_filter :authenticate, except: [:notifications]
  before_filter :load_resource, except: [:retract, :notifications]
  before_filter :authorize_resource, except: [:retract, :notifications]
  
  def notifications
    @user = User.find_by_signup_token(params[:signup_token])
    raise "Access Denied: Attempt to change settings" if current_user && current_user != @user
    
    @notification_settings = @user.notification_settings
    unless request.get?
      @user.notification_settings.update_attributes(params[:notification_settings])
      flash[:success] = "You're notification settings have been saved. Rock on."
    end
  end
  
  def edit
    @title = "Edit Profile"
  end
  
  def update
    if @user.update_attributes(params[:user])
      if request.xhr?
        render json: { status: "success" }
      else
        flash[:success] = "Profile successfully updated."
        redirect_to profile_path(@user.username)
      end
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
  
  def follow
    existing_subscription = current_user.subscriptions.find_by_followed_id(params[:followed_id])
    if existing_subscription
      existing_subscription.destroy!
    else
      current_user.subscriptions.create!(followed_id: params[:followed_id])
    end
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
end
