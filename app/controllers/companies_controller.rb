class CompaniesController < ApplicationController
	before_filter :authenticate
	# before_filter :correct_user, :only => [:edit, :update]
	before_filter :admin_user, :only => [:index]
	
	def new
		@company = Company.new
		@title = "Company Registration"
	end
	
	def create
		@company = Company.new(params[:company])
		if @company.save
			flash[:success] = "Welcome to your company account!"
			redirect_to @company
		else
			@title = "Company Registration"
			render 'new'
		end
	end
  
	def show
		@company = Company.find(params[:id])
		@company_users = CompanyUser.find(:all, :conditions => ["company_id = ? AND user_id IS NOT NULL", @company.id])
		@title = @company.name
	end
	
	def edit
		@company = Company.find(params[:id])
		@title = "Company Settings"
	end
	
	def index
		@companies = Company.paginate(:page => params[:page])
		@title = "All companies"
	end
	
	# def update
		# @user = User.find(params[:id])
		# if @user.update_attributes(params[:user])
			# flash[:success] = "Profile successfully updated."
			# redirect_to @user
		# else
			# @title = "Settings"
			# render 'edit'
		# end
	# end
	
	# def destroy
		# User.find_by_id(params[:id]).destroy
		# flash[:success] = "User destroyed"
		# redirect_to users_path
	# end
	
	private
		# def correct_user
			# @user = User.find(params[:id])
			# redirect_to root_path unless current_user?(@user)
		# end
		
		def admin_user
			redirect_to(root_path) unless current_user.admin?
		end
end
