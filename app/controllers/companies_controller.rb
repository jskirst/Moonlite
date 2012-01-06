class CompaniesController < ApplicationController
	before_filter :authenticate
	before_filter :admin_only, :only => [:new, :create, :index]
	before_filter :admin_or_company_admin, :only => [:show, :edit]
	
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
		@unregistered_company_users = CompanyUser.find(:all, :conditions => ["company_id = ? AND user_id IS NULL", @company.id])
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
	
	private
		def admin_only
			redirect_to(root_path) unless (current_user.admin?)
		end
	
		def admin_or_company_admin
			redirect_to(root_path) unless (current_user.admin? || current_user.company_admin?)
		end
end
