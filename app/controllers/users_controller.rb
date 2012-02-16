class UsersController < ApplicationController
	before_filter :authenticate, :except => [:accept, :join]
	before_filter :company_admin, :except => [:accept, :join, :show, :edit, :update]
	
	def new
		@company = Company.find(params[:company_id])
		@user = User.new
		@title = "Invite user"
	end
	
	def create
		nil_company_message = "The company you tried to add a user to did not exist."
		error_message = "Something bad happened and a new invitation could not be sent."
		success_message = "Successfully invited."
		
		@company = Company.find_by_id(params[:user][:company_id])
		if @company.nil?
			flash[:error] = nil_company_message
			redirect_to root_path
		else
			params[:user].delete("company_id")
			params[:user][:name] = "pending"
			params[:user][:password] = "pending"
			params[:user][:password_confirmation] = "pending"
			@user = @company.users.build(params[:user])
			if @user.save
				@user.send_invitation_email
				flash[:success] = success_message
				redirect_to @company
			else
				@title = "Invite user"
				render "new"
			end
		end
	end
	
	def accept
		@user = User.find(:first, :conditions => ["signup_token = ?", params[:id]])
		if @user.nil?
			redirect_to root_path
		else
			@title = @user.company.name
		end
	end
	
	def join
		if params[:user].nil?
			redirect_to root_path and return
		end
		
		@user = User.find_by_signup_token(params[:user][:signup_token])
		if @user.nil?
			redirect_to root_path and return
		end
		
		if @user.update_attributes(params[:user])
			@user.reload
			sign_in @user
			flash[:success] = "Welcome to the Moonlite!"
			redirect_to @user
		else
			@title = "Accept invite"
			render "accept"
		end
	end
  
	def show
		@user = User.find_by_id(params[:id])
		if @user.nil?
			redirect_to root_path
		else
			@enrolled_paths = @user.enrolled_paths.find(:all, :conditions => ["paths.is_public = ?", true])
			@user_achievements = @user.user_achievements.joins(:achievement)
			@company = @user.company
			@title = @user.name
		end
	end
	
	def index
		@users = User.paginate(:page => params[:page])
		@title = "All users"
	end
	
	def edit
		@user = User.find(params[:id])
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
		@user = User.find_by_id(params[:id])
		if @user.nil?
			flash[:error] = "No such user exists."
			redirect_to current_user.company
		else
			@user.destroy
			flash[:success] = "User destroyed"
			redirect_to current_user.company
		end
	end
	
	private		
		def admin_user
			redirect_to(root_path) unless current_user.admin?
		end
end
