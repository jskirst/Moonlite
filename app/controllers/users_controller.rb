class UsersController < ApplicationController
  before_filter :authenticate, except: [:request_send, :send_reset, :request_reset, :reset_password, :show]
  before_filter :find_by_id, except: [:request_reset, :request_send, :reset_password]
  before_filter :company_admin_or_admin_only, only: [:destroy, :edit_role, :update_role]
  before_filter :user_only,  only: [:edit, :update]
  before_filter :admin_only, only: [:adminize, :index, :set_type]
  
  def show
   @enrolled_paths = @user.enrolled_paths.where("paths.is_public = ?", true)
   @title = @user.name
  end
  
  def index
    if params[:search]
      @users = User.paginate(:page => params[:page], 
        :conditions => ["is_fake_user = ? and is_test_user = ? and (name ILIKE ? or email ILIKE ?)", 
          false, false, "%#{params[:search]}%", "%#{params[:search]}%"], :order => "id DESC")
    else
      @users = User.paginate(:page => params[:page], :conditions => ["is_fake_user = ? and is_test_user = ?", false, false], :order => "id DESC")
    end
  end
  
  def usage_reports
    @reports = current_company.usage_reports.all(:order => "id DESC")
  end
  
  def edit
    @title = "Settings"
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
  
  def update
    if @user.update_attributes(params[:user])
      respond_to do |format|
        format.html do
          if request.xhr?
            render :json => {:status => "success"}
          else params[:user][:path_id]
            flash[:success] = "Profile successfully updated."
            redirect_back_or_to @user
          end
        end
      end
    else
      flash[:error] = @user.errors.full_messages.join(". ")
      respond_to do |format|
        format.html do
          if request.xhr?
            render :json => @user.errors
          elsif params[:user][:path_id]
            redirect_back_or_to continue_path_path(id: params[:user][:path_id])
          else
            render 'edit'
          end
        end
      end
    end
  end
  
  def set_type
    @user.is_fake_user = true if params[:type] == "fake"
    @user.is_test_user = true if params[:type] == "test"
    @user.admin = true if params[:type] == "admin"

    if @user.save
      flash[:success] = "User is now of type : #{params[:type]}"
    else
      flash[:error] = "User could not be made type: #{params[:type]}"
    end
    redirect_to users_path
  end
  
  def request_send
  end
  
  def send_reset
    @user = User.find_by_email(params[:email])
    if @user && @user.send_password_reset
      flash[:success] = "Please check your email for your password reset link."
    else
      flash[:error] = "There was an error trying to send your reset your password. Please try again."
    end
    redirect_to root_path
  end
  
  def request_reset
    @user = User.find_by_signup_token(params[:id])
  end
  
  def reset_password
    @user = User.find_by_signup_token(params[:user][:signup_token])
    if @user.save && !params[:user][:password].blank?
      sign_in @user
      redirect_to root_path, notice: "Your password has been successfully reset."
    else
      flash[:alert] = "There was an error saving your new password. Please try again."
      render "request_reset"
    end
  end
  
  def destroy
    if @user == current_user
      respond_to do |f|
        f.html { render partial: "shared/error_message", locals: { message: "Cannot delete yourself." } }
      end
    else
      @user.destroy
      respond_to do |f|
        f.html { render partial: "shared/success_message", locals: { message: "User successfully deleted." } }
      end
    end
  end
  
  private
    def find_by_id
      @user = User.find(params[:id]) if params[:id]
    end
  
    def company_admin_or_admin_only
      company_id = @user.nil? ? (params[:company_id] || params[:user][:company_id]) : @user.company.id
      unless (current_user.admin? || (@enable_administration && current_company.id == company_id.to_i))
        redirect_to root_path, alert: "You do not have the ability to create or edit users."
      end
    end
  
    def user_only
      redirect_to root_path unless current_user.id == @user.id
    end
end
