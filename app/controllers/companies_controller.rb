class CompaniesController < ApplicationController
	before_filter :authenticate, :except => [:accept, :join]
	before_filter :admin_only, :only => [:new, :create, :index]
	before_filter :has_access?, :only => [:show, :edit, :update]
	before_filter :get_company_from_id, :only => [:show, :edit, :edit_rolls, :update]
	before_filter :verify_owner, :only => [:show, :edit, :update]
	
	def new
		@company = Company.new
		@title = "Company Registration"
	end
	
	def create
		@company = Company.new(params[:company])
		if @company.save
			create_first_admin(@company, params[:admin_email])
			flash[:success] = "Welcome to your company account!"
			redirect_to @company
		else
			@title = "Company Registration"
			render 'new'
		end
	end
  
	def show
		@users = @company.users.includes(:user_roll).find(:all, :conditions => ["company_id = ? AND name != ?", @company.id, "pending"])
		@unregistered_users =  @company.users.find(:all, :conditions => ["company_id = ? AND name = ?", @company.id, "pending"])
		@title = @company.name
	end
	
	def edit
		@title = "Company Settings"
		@categories = @company.categories.all
		if Rails.env.production?
			@signup_url = "http://www.projectmoonlite.com/companies/#{@company.signup_token}/join"
		else
			@signup_url = "http://localhost:3000/companies/#{@company.signup_token}/join"
		end
	end
	
	def edit_rolls
		@title = "User Rolls"
		@user_rolls = @company.user_rolls.all
	end
	
	def update
		if @company.update_attributes(params[:company])
			flash[:success] = "Company update successful."
			redirect_to @company
		else
			@title = "Edit company"
			render "edit"
		end
	end
	
	def index
		@companies = Company.paginate(:page => params[:page])
		@title = "All companies"
	end
	
	def join
		redirect_to root_path if signed_in?
		@user_roll = UserRoll.where("signup_token = ?", params[:id]).first
		@company = @user_roll.company
		if @company.nil?
			redirect_to root_path
		else
			@user = @company.users.new
		end
	end
	
	def accept
		@user_roll = UserRoll.where("signup_token = ?", params[:id]).first
		@company = @user_roll.company
		if @company.nil?
			redirect_to root_path
		else
			@user = @company.users.build(params[:user])
			@user.password = params[:user][:password]
			@user.password_confirmation = params[:user][:password_confirmation]
			@user.user_roll_id = @user_roll.id
			if @user.save
				flash[:success] = "Welcome to Moonlite!"
				@user.reload
				sign_in @user
				
				logger.debug "BEGINNING ATTACK RUN."
				logger.debug @company.enable_auto_enroll
				if @company.enable_auto_enroll
					company_paths = @company.paths.where("is_published = ?", true)
					logger.debug company_paths
					company_paths.each do |p|
						@user.enroll!(p)
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
			redirect_to(root_path) unless (current_user.admin? || @enable_administration)
		end
		
		def get_company_from_id
			@company = Company.find_by_id(params[:id])
			@owner_id = @company.id
			if @company.nil?
				flash[:error] = "This is not a valid company."
				redirect_to root_path
			end
		end
		
		def verify_owner
			unless current_user.admin?
				unless @owner_id == current_user.company_id
					flash[:error] = "You do not have access to this data."
					redirect_to root_path
				end
			end
		end
		
		def create_first_admin(company, email)
			tmp = "pending"
			new_admin = company.users.build({:name => tmp, :email => email, :password => tmp, :password_confirmation => tmp})
			return new_admin.save
		end
end
