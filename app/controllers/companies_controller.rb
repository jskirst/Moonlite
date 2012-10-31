class CompaniesController < ApplicationController
  before_filter :authenticate, :except => [:accept, :join]
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
    @mode = "overview"
    @company = current_user.company
    @user_roles = current_user.company.user_roles
    if params[:search]
      @users = User.paginate(:page => params[:page], 
        :conditions => ["company_id = ? and (name ILIKE ? or email ILIKE ?)", 
          @company.id, "%#{params[:search]}%", "%#{params[:search]}%"])
    else
      if params[:sort] == "votes"
        @users = User.paginate(:page => params[:page], :conditions => ["company_id = ?", @company.id])
      else
        @sort = "points"
        @users = User.paginate(:page => params[:page], :conditions => ["company_id = ?", @company.id])
      end
    end
  end
  
  def edit
    @mode = "settings"
    @company = current_company
    @categories = @company.categories.all
    @user_roles = @company.user_roles.all
  end
  
  def users
    @mode = "users"
    @company = current_company
    if params[:search]
      @users = User.paginate(
        page: params[:page], 
        conditions: ["company_id = ? and (name ILIKE ? or email ILIKE ?)", 
        @company.id, "%#{params[:search]}%", "%#{params[:search]}%"]
      )
    else
      @users = User.paginate(
        page: params[:page], 
        conditions: ["company_id = ?", @company.id],
        order: "earned_points DESC"
      )
    end
  end
  
  def paths
    @mode = "paths"
    @company = current_company
    if params[:search]
      @paths = @company.all_paths.paginate(
        page: params[:page], 
        conditions: ["company_id = ? and name ILIKE ?", 
        @company.id, "%#{params[:search]}%"]
      )
    else
      @paths = @company.all_paths.paginate(
        page: params[:page], 
        conditions: ["company_id = ?", @company.id]
      )
    end
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
        @user.reload
        sign_in @user
        flash[:success] = "Welcome to #{@company.name}"
        
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
    def admin_only
      redirect_to(root_path) unless (current_user.admin?)
    end
  
    def has_access?
      unless @enable_administration
        flash[:error] = "You do not have access to this data."
        redirect_to root_path
      end
    end
end
