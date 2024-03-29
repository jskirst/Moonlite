class UsersController < ApplicationController
  include NewsfeedHelper
  
  before_filter :authenticate, except: [:new, :create, :notifications, :professional, :index, :hovercard]
  before_filter :load_resource, except: [:new, :create, :retract, :notifications, :professional, :index]
  before_filter :authorize_resource, except: [:new, :create, :retract, :notifications, :professional, :follow, :unfollow, :index, :hovercard, :possess]
  
  def new
    @user = User.new
    @hide_background = true
    redirect_to root_url if current_user
  end
  
  def create
    @user = User.new
    @user.name = params[:user][:name]
    @user.email = params[:user][:email]
    @user.password = params[:user][:password]
    if @user.save
      flash[:success] = "MetaBright account created."
      sign_in(@user)
      redirect_to params[:redirect_url] or root_path
    else
      flash[:error] = @user.errors.full_messages.join(", ")
      @hide_background = true
      render "new"
    end
  end
  
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
    @user = User.where(signup_token: params[:id]).first
    raise "Access Denied: Attempt to change settings" if current_user && current_user != @user
    
    @notification_settings = @user.notification_settings
    unless request.get?
      @user.notification_settings.update_attributes(params[:notification_settings])
      flash[:success] = "Your notification settings have been saved. Rock on."
    end
  end

  def publicize
    current_user.update_attribute(:private_at, nil)
    current_user.enrollments.each do |e|
      if e.path.group_id.nil?
        e.update_attribute(:private_at, nil)
      end
    end
    redirect_to profile_path(current_user.username)
  end
  
  def privatize
    enrollment = current_user.enrollments.where(id: params[:enrollment_id]).first
    if enrollment.private_at
      enrollment.private_at = nil
    else
      enrollment.private_at = Time.now
    end
    enrollment.save!
    redirect_to profile_path(current_user.username)
    # render json: @enrollment.to_json 
  end
  
  def professional
    @user = User.where(signup_token: params[:id]).first
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
      @user_custom_style.styles = params[:custom_style][:styles]
      @user_custom_style.mode = params[:custom_style][:mode]
      @user_custom_style.save
      if @user_custom_style.css_validation_errors.size > 0
        flash.now[:error] = @user_custom_style.css_validation_errors.to_s
      else
        flash.now[:success] = "Your styles have been saved."
      end
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
        if params[:redirect_url]
          redirect_to params[:redirect_url]
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
        if params[:error_redirect_url]
          redirect_to params[:error_redirect_url]
        elsif params[:redirect_url]
          redirect_to params[:redirect_url]
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
      @enrollments = @user.enrollments.where(private_at: nil).where("total_points > ?", 100).order("total_points DESC").includes(:path)
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
      unless @user == current_user or (@admin_group and @user.groups.find(@admin_group))
        raise "Access Denied" 
      end
    end
end
