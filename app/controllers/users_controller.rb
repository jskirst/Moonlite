class UsersController < ApplicationController
  include NewsfeedHelper
  
  before_filter :authenticate, except: [:notifications, :index]
  before_filter :load_resource, except: [:retract, :notifications, :professional, :index]
  before_filter :authorize_resource, except: [:retract, :notifications, :professional, :follow, :unfollow, :index]
  
  def show
    redirect_to profile_path(@user.username)
  end
  
  def index
    permalink = params[:group]
    email = params[:email]
    
    group = Group.find_by_permalink(permalink)
    if group and @user = group.users.find_by_email(email)
      respond_to do |format|
        format.html { render text: @user.to_json }
        format.json { render json: @user.to_json }
      end
    else
      render json: { success: false, message: "Either the group or user supplied do not exist." }, status: 401
    end
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
    existing_event = @user.user_events.find_by_content("#{current_user} is now following you!")
    if current_user.following?(@user)
      current_user.unfollow!(@user)
      existing_event.destroy if existing_event
    else
      current_user.follow!(@user)
      unless existing_event
        UserEvent.log_event(@user, "#{current_user} is now following you!", current_user, profile_path(current_user.username), current_user.picture)
      end
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
