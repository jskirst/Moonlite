class UserRolesController < ApplicationController
  before_filter :authenticate
  before_filter :get_user_role_from_id, :except => [:index, :new, :create]
  before_filter :has_access?
  
  def index
    @user_roles = current_user.company.user_roles.all
    @company = current_user.company
  end
  
  def new
    @title = "New user role"
    @form_mode = "new"
    @user_role = UserRole.new
    render "form"
  end
  
  def create
    @user_role = current_user.company.user_roles.new(params[:user_role])
    if @user_role.save
      redirect_to user_roles_path, notice: "User role created."
    else
      @title = "New user role"
      @form_mode = "new"
      render "form"
    end
  end
  
  def edit
    @users = @user_role.users
    @title = "Edit user role"
    @form_mode = "edit"
    render "form"
  end
  
  def update
    if @user_role.update_attributes(params[:user_role])
      redirect_to user_roles_path, notice: "User Role updated."
    else
      @title = "Edit User Role"
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
  
  private
    def get_user_role_from_id
      @user_role = current_user.company.user_roles.find(params[:id])
      @company = @user_role.company
    end
  
    def has_access?
      unless @enable_administration
        redirect_to root_path, alert: "You do not have the ability edit user roles."
      end
      
      if @company && @company != current_user.company
        redirect_to root_path, alert: "You do not have access to this organizations data."
      end
    end
end