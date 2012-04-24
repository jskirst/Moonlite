class UsersController < ApplicationController
	before_filter :authenticate, :except => [:accept, :join, :request_send, :send_reset, :request_reset, :reset_password]
	before_filter :company_admin_or_admin_only, :only => [:new, :create, :destroy]
	before_filter :user_only,	:only => [:edit, :update]
	before_filter :admin_only, :only => [:adminize]
	
	def new
		@company = Company.find(params[:company_id])
		@user = User.new
		@title = "Invite user"
	end
	
	def create
		nil_company_message = "The company you tried to add a user to did not exist."
		error_message = "Something bad happened and a new invitation could not be sent."
		success_message = "Successfully invited."
		
		@company = Company.find(params[:user][:company_id])
		if @company.nil?
			flash[:error] = nil_company_message
			redirect_to root_path
		else
			@user = @company.users.new
			@user.name = "pending"
			@user.password = "pending"
			@user.password_confirmation = "pending"
			@user.email = params[:user][:email]
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
			if @user.name == "pending"
				@user.name = nil
				@title = @user.company.name
			else
				redirect_to root_path
			end
		end
	end
	
	def join
		@user = User.find_by_signup_token(params[:user][:signup_token])
		if @user.nil? || @user.name != "pending"
			redirect_to root_path and return
		end
		
		@user.name = params[:user]
		@user.password = params[:user][:password]
		@user.password_confirmation = params[:user][:password_confirmation]
		
		if @user.save
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
      @rank = Leaderboard.get_rank(current_user)
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
		@user.name = params[:user][:name] if params[:user][:name] 
		@user.email = params[:user][:email] if params[:user][:email] 
		@user.image_url = params[:user][:image_url] if params[:user][:image_url] 
		@user.password = params[:user][:password] if params[:user][:password] 
		@user.password_confirmation = params[:user][:password_confirmation] if params[:user][:password_confirmation] 
		if @user.save
			flash[:success] = "Profile successfully updated."
			@user.reload
			sign_in(@user)
			redirect_to @user
		else
			@title = "Settings"
			render 'edit'
		end
	end
	
	def adminize
		@user = User.find(params[:id])
		unless @user.admin == true
			@user.toggle(:admin)
			if @user.save
				flash[:success] = "User is now an admin."
			else
				flash[:error] = "User could not be made an admin."
			end
		end
		redirect_to users_path
	end
	
	def request_send
	end
	
	def send_reset
		@user = User.find_by_email(params[:email])
		if @user.nil?
			flash[:error] = "No such user exists."
		else
			if @user.send_password_reset
				flash[:success] = "Please check your email for your password reset link."
			else
				flash[:error] = "There was an error trying to send your reset your password. Please try again."
			end
		end
		redirect_to root_path
	end
	
	def request_reset
		@user = User.find(:first, :conditions => ["signup_token = ?", params[:id]])
		redirect_to root_path if @user.nil?
	end
	
	def reset_password
		@user = User.find_by_signup_token(params[:user][:signup_token])
		@user.password = params[:user][:password]
		@user.password_confirmation = params[:user][:password_confirmation]
		if @user.save
			flash[:success] = "Your password has been successfully reset."
			redirect_to root_path
		else
			flash[:error] = "There was an error saving your new password. Please try again."
			render "request_reset"
		end
	end
	
	def destroy
		@user = User.find_by_id(params[:id])
		if @user == current_user
			flash[:error] = "You cannot remove yourself from the equation."
			redirect_to current_user.company
		else
			@user.destroy
			flash[:success] = "User destroyed"
			redirect_to current_user.company
		end
	end
	
	private
		def company_admin_or_admin_only
			if params[:id]
				company_id = User.find(params[:id]).company.id
			else
				company_id = params[:company_id] || params[:user][:company_id]
			end
			
			unless (current_user.admin? || (current_user.company_admin? && current_user.company.id == company_id.to_i))
				flash[:error] = "You do not have access to this functionality."
				redirect_to root_path 
			end
		end
	
		def user_only
			redirect_to root_path unless current_user.id == params[:id].to_i
		end
	
		def admin_only
			redirect_to(root_path) unless current_user.admin?
		end
end
