class UserRollsController < ApplicationController
	before_filter :authenticate
	before_filter :get_user_roll_from_id, :except => [:index, :new, :create]
	before_filter :has_access?
  
	def index
		@user_rolls = current_user.company.user_rolls.all
		@company = current_user.company
	end
	
	def new
		@title = "New user roll"
		@form_mode = "new"
		@user_roll = UserRoll.new
		render "form"
	end
	
	def create
		@user_roll = current_user.company.user_rolls.new(params[:user_roll])
		if @user_roll.save
			flash[:success] = "User roll created."
			redirect_to user_rolls_path
		else
			@title = "New user roll"
			@form_mode = "new"
			render "form"
		end
	end
	
	def edit
		@users = @user_roll.users
		@title = "Edit user roll"
		@form_mode = "edit"
		render "form"
	end
	
	def update
		if @user_roll.update_attributes(params[:user_roll])
			flash[:success] = "User Roll updated."
			redirect_to user_rolls_path
		else
			@title = "Edit User Roll"
			@form_mode = "edit"
			render "form"
		end
	end
	
	def destroy
		unless @user_roll.users.empty?
			redirect_to user_rolls_path
			flash[:error] = "You cannot delete a user roll until all users have been removed from it."
			return
		end
		
		if @user_roll.destroy
			flash[:success] = "User roll successfully removed."
		else
			flash[:error] = "User roll could not be deleted. Please try again."
		end
		redirect_to user_rolls_path
	end
	
	private
		def get_user_roll_from_id
			@user_roll = current_user.company.user_rolls.find(params[:id])
			if @user_roll.nil?
				flash[:error] = "This is not a valid company."
				redirect_to root_path
			else
				@company = @user_roll.company
			end
		end
	
		def has_access?
			unless @enable_administration
				flash[:error] = "You do not have access to this functionality."
				redirect_to root_path
				return
			end
			
			if @company && @company != current_user.company
				flash[:error] = "You do not have access to this organizations data."
				redirect_to root_path
			end
		end
end