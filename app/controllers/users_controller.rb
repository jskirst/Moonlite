class UsersController < ApplicationController
	before_filter :check_environment, :except => [:accept, :show, :index, :create, :verify, :edit, :update, :destroy]
	before_filter :authenticate, :except => [:new, :create, :accept, :verify]
	before_filter :correct_user, :except => [:new, :accept, :create, :verify, :show, :index, :destroy]
	before_filter :admin_user, :except => [:new, :accept, :verify, :create, :show, :edit, :update]
	
	def new
		@user = User.new
		@title = "Sign up"
	end
	
	def accept
		@company_user = CompanyUser.find(:first, :conditions => ["token1 = ?", params[:id]])
		if @company_user.nil?
			redirect_to root_path
		else
			@company = Company.find_by_id(@company_user.company_id)
			@title = @company.name
			@user = User.new
			render 'new'
		end
	end
  
	def show
		@user = User.find(params[:id])
		if @user.nil?
			redirect_to root_path
		else
			@enrolled_paths = @user.enrolled_paths.paginate(:page => params[:page])
			
			@company_user = CompanyUser.find_by_user_id(@user.id)
			if !@company_user.nil?
				@company = @company_user.company
			end
			@title = @user.name
		end
	end
	
	def index
		@users = User.paginate(:page => params[:page])
		@title = "All users"
	end
		
	def create
		token1 = params[:user][:token1]
		if !token1.nil?
			@company_user = CompanyUser.find(:first, :conditions => ["token1 = ?", token1])
			if @company_user.nil?
				redirect_to root_path and return
			end
		end
		
		@user = User.new(params[:user])
		if @user.save
			@user.reload
			sign_in @user
			if @company_user.nil?
				flash[:success] = "Welcome to the sample app!"
				redirect_to @user
			else
				@company_user.user_id = @user.id
				@company_user.save!
				#@company_user.send_verification_email
				flash[:success] = "Welcome to the sample app!"
				redirect_to @user
			end
		else
			@title = "Sign up"
			render 'new'
		end
	end
	
	def verify
		@company_user = CompanyUser.find(:first, :conditions => ["token2 = ?", params[:id]])
		@title = "User Verification"
	end
	
	def edit
		@title = "Settings"
	end
	
	def update
		@user = User.find(params[:id])
		if @user.update_attributes(params[:user])
			flash[:success] = "Profile successfully updated."
			redirect_to @user
		else
			@title = "Settings"
			render 'edit'
		end
	end
	
	def destroy
		User.find_by_id(params[:id]).destroy
		flash[:success] = "User destroyed"
		redirect_to users_path
	end
	
	private
		def check_environment
			if Rails.env.production?
				flash[:notice] = "We are not currently taking signups right now. Check back soon!"
				redirect_to landing_path
			end
		end
	
		def correct_user
			@user = User.find(params[:id])
			redirect_to root_path unless current_user?(@user)
		end
		
		def admin_user
			redirect_to(root_path) unless current_user.admin?
		end
end
