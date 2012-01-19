class CompanyUsersController < ApplicationController
	before_filter :authenticate, :only => [:new, :create]
	before_filter :authorized_user, :only => :destroy
	
	def new
		@company = Company.find(params[:company])
		@company_user = CompanyUser.new
		@title = "Invite user"
	end
	
	def create
		nil_company_message = "The company you tried to add a user to did not exist."
		error_message = "Something bad happened and a new invitation could not be sent."
		success_message = "Successfully invited."
		
		@company = Company.find_by_id(params[:company_user][:company_id])
		if @company.nil?
			flash[:error] = nil_company_message
			redirect_to root_path
		else
			@company_user = @company.company_users.build(params[:company_user])
			if @company_user.save
				@company_user.send_invitation_email
				flash[:success] = success_message
				redirect_to @company
			else
				flash[:error] = error_message
				redirect_to root_path
			end
		end
	end
	
	private
		def authorized_user
			# @enrollment = Enrollment.find(params[:id])
			# redirect_to root_path unless current_user?(@enrollment.user)
		end
end