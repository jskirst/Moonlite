class UserRolesController < ApplicationController
  before_filter :authenticate
  before_filter :load_resource, except: [:index, :new, :create, :update_user]
  before_filter :authorize_resource
  
  def index
    @mode = "roles"
    @user_roles = current_user.company.user_roles.all
    @company = current_user.company
  end
  
  def new
    @form_mode = "new"
    @user_role = UserRole.new
    render "form"
  end
  
  def create
    @user_role = current_user.company.user_roles.new(params[:user_role])
    if @user_role.save
      redirect_to user_roles_path, notice: "User role created."
    else
      @form_mode = "new"
      render "form"
    end
  end
  
  def edit
    @users = @user_role.users
    @form_mode = "edit"
    render "form"
  end
  
  def update
    if @user_role.update_attributes(params[:user_role])
      redirect_to user_roles_path, notice: "User Role updated."
    else
      @form_mode = "edit"
      render "form"
    end
  end
  
  def invite
    if params[:email]
      @user_role.send_invitation_email(params[:email])
      flash[:success] = "Invitation sent to #{params[:email]}."
    end
  end
  
  def destroy
    unless @user_role.users.empty?
      redirect_to user_roles_path, alert: "You cannot delete a user role until all users have been removed from it."
      return
    end
    
    if @user_role.destroy
      flash[:success] = "User role successfully removed."
    else
      flash[:error] = "User role could not be deleted. Please try again."
    end
    redirect_to user_roles_path
  end
  
  def update_user
    if request.get?
      @user_roles = current_company.user_roles
      @user = User.find(params[:user_id])
      render "update_user"
    else
      @user = User.find(params[:user_id])
      @user_role = current_company.user_roles.find(params[:user][:user_role_id])
      @user.user_role_id = @user_role.id
      if @user.save
        redirect_to admin_users_path, flash: { success: "User role changed successfully." }
      else
        raise "Runtime error" + current_user.to_yaml + @user.to_yaml
      end
    end
  end
  
  private
    def load_resource
      @user_role = current_user.company.user_roles.find(params[:id])
      @company = @user_role.company
    end
  
    def authorize_resource
      raise "Access Denied" unless @enable_administration
    end
end