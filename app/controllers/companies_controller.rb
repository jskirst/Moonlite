class CompaniesController < ApplicationController
  before_filter :authenticate, :except => [:accept, :join]
  before_filter :get_company_from_id, :except => [:new, :create, :index, :accept, :join]
  before_filter :admin_only, :only => [:new, :create, :index]
  before_filter :has_access?, :only => [:show, :edit, :update]
  
  def new
    @company = Company.new
    @title = "Company Registration"
  end
  
  def create
    @company = Company.new(params[:company])
    if @company.save
      flash[:success] = "New account created"
      redirect_to @company
    else
      @title = "Company Registration"
      render 'new'
    end
  end
  
  def show
    @users = @company.users.includes(:user_role).find(:all, :conditions => ["company_id = ? AND name != ?", @company.id, "pending"])
    @unregistered_users =  @company.users.find(:all, :conditions => ["company_id = ? AND name = ?", @company.id, "pending"])
    @title = @company.name
  end
  
  def edit
    @title = "Company Settings"
    @categories = @company.categories.all
    @user_roles = @company.user_roles.all
  end
  
  def update
    if @company.update_attributes(params[:company])
      flash[:success] = "Company update successful."
      redirect_to @company
    else
      @title = "Edit company"
      @categories = @company.categories.all
      render "edit"
    end
  end
  
  def index
    @companies = Company.paginate(:page => params[:page])
    @title = "All companies"
  end
  
  def join
    if signed_in?
      flash[:info] = "You cannot access this link becaue you are already signed in. Please signout if you would like to create another account."
      redirect_to root_path
      return
    end
    @user_role = UserRole.where("signup_token = ?", params[:id]).first
    @company = @user_role.company
    if @company.nil?
      redirect_to root_path
    else
      @user = @company.users.new
    end
  end
  
  def accept
    @user_role = UserRole.where("signup_token = ?", params[:id]).first
    @company = @user_role.company
    if @company.nil?
      redirect_to root_path
    else
      @user = @company.users.build(params[:user])
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
      @user.user_role_id = @user_role.id
      if @user.save
        flash[:success] = "Welcome to Moonlite!"
        @user.reload
        sign_in @user
        
        determine_enabled_features
        if @enable_auto_enroll
          company_paths = @company.paths.where("is_published = ?", true)
          logger.debug company_paths
          company_paths.each do |p|
            if p.path_user_roles.find_by_user_role_id(@user.user_role_id)
              @user.enroll!(p)
            end
          end
        end
        
        redirect_to root_path
      else
        flash[:error] = "There was a problem with your signup."
        render "join"
      end
    end
  end
  
  private
    def get_company_from_id
      @company = Company.find_by_id(params[:id])
      if @company.nil?
        flash[:error] = "This is not a valid company."
        redirect_to root_path
      end
    end
  
    def admin_only
      redirect_to(root_path) unless (current_user.admin?)
    end
  
    def has_access?
      unless current_user.admin?
        unless @company.id == current_user.company_id && @enable_administration
          flash[:error] = "You do not have access to this data."
          redirect_to root_path
        end
      end
    end
end
