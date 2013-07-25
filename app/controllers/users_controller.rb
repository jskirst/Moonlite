class UsersController < ApplicationController
  include NewsfeedHelper
  
  before_filter :authenticate, except: [:notifications, :index, :hovercard]
  before_filter :load_resource, except: [:retract, :notifications, :professional, :index]
  before_filter :authorize_resource, except: [:retract, :notifications, :professional, :follow, :unfollow, :index, :hovercard, :possess]
  
  def show
    redirect_to profile_path(@user.username)
  end
  
  def index
    token = params[:token]
    email = params[:email]
    
    group = Group.find_by_token(token)
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
  
  def style
    @user_custom_style = current_user.custom_style
    unless @user_custom_style
      @user_custom_style = CustomStyle.new
      @user_custom_style.owner_id = current_user.id
      @user_custom_style.owner_type = "User"
      @user_custom_style.save!
    end
    
    unless request.get?
      @user_custom_style.update_attributes(params[:custom_style])
      flash[:success] = "Your styles have been saved."
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
        flash[:success] = "User account updated."
        if params[:redirect_uri]
          redirect_to params[:redirect_uri]
        elsif place_to_go_back_to?
          redirect_back
        else
          redirect_to edit_user_path(@user.username)
        end
      end
    else
      if request.xhr?
        render json: { status: "error" }
      else
        flash[:error] = @user.errors.full_messages.join(". ")
        if params[:redirect_uri]
          redirect_to params[:redirect_uri]
        elsif place_to_go_back_to?
          redirect_back
        else
          redirect_to profile_path(@user.username)
        end
      end
    end
  end
  
  def destroy
    sign_out
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
    
    if request.xhr?
      render json: { status: :success }
    else
      redirect_to profile_path(@user.username)
    end
  end
  
  def hovercard
    if request.xhr?
      @enrollments = @user.enrollments.order("total_points DESC").includes(:path)
      @user_personas = @user.user_personas.includes(:persona)
      render partial: "users/hovercard"
    else
      redirect_to profile_url(@user.username)
    end
  end
  
  def subregion
    render partial: 'shared/subregion', locals: { form: nil }
  end
  
  def possess
    raise "Access Denied: Cannot possess" unless @enable_administration
    sign_in(@user)
    redirect_to root_url
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
