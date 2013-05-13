class UsersController < ApplicationController
  include NewsfeedHelper
  
  before_filter :authenticate, except: [:notifications]
  before_filter :load_resource, except: [:retract, :notifications, :professional]
  before_filter :authorize_resource, except: [:retract, :notifications, :professional, :follow, :unfollow]
  
  def show
    redirect_to profile_path(@user.username)
  end
  
  def notifications
    @user = User.find_by_signup_token(params[:signup_token])
    raise "Access Denied: Attempt to change settings" if current_user && current_user != @user
    
    @notification_settings = @user.notification_settings
    unless request.get?
      @user.notification_settings.update_attributes(params[:notification_settings])
      flash[:success] = "Your notification settings have been saved. Rock on."
    end
  end
  
  def professional
    @user = User.find_by_signup_token(params[:signup_token])
    raise "Access Denied: Attempt to change settings" if current_user && current_user != @user
    
    unless request.get?
      @user.update_attributes(params[:user])
      flash[:success] = "Your settings have been saved. Rock on."
    end
  end
  
  def edit
    @title = "Edit Profile"
  end
  
  def update
    if @user.update_attributes(params[:user])
      if params[:user][:password]
        @user.reload
        sign_in(@user)
      end
      
      if request.xhr?
        render json: { status: "success" }
      else
        flash[:success] = "Profile successfully updated."
        redirect_to profile_path(@user.username)
      end
    else
      if request.xhr?
        render json: { status: "error" }
      else
        flash[:error] = @user.errors.full_messages.join(". ")
        redirect_to profile_path(@user.username)
      end
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
    render json: { status: :success }
  end
  
  def follow
    if current_user.following?(@user)
      current_user.unfollow!(@user)
    else
      current_user.follow!(@user)
    end
    render json: { status: :success } 
  end
  
  private
    def load_resource
      @user = User.find_by_username(params[:username]) if params[:username]
      @user = User.find_by_username(params[:id]) unless @user
      @user = User.find_by_id(params[:id]) unless @user
      redirect_to root_path and return if @user.nil?
    end
    
    def authorize_resource
      raise "Access Denied" unless @user == current_user
    end
end
