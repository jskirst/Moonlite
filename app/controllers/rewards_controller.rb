class RewardsController < ApplicationController
	before_filter :authenticate
	before_filter :admin_or_company_admin, :except => [:show, :index]
	before_filter :correct_company
	
	def new
		@reward = Reward.new
		@title = "New Store Item"
		@form_title = "New Store Item"
		render "rewards/reward_form"
	end
	
	def create
		@reward = @company.rewards.build(params[:reward])
		if @reward.save
			flash[:success] = "Store item created."
			redirect_to @reward
		else
			@title = "New"
			@form_title = @title
			@company_id = @company.id
			render "rewards/reward_form"
		end
	end
	
	def index
		@rewards = Reward.paginate(:page => params[:page], :conditions => ["company_id = ?", @company.id])
	end
	
	def show
		@title = @reward.name
	end
	
	def edit
		@title = "Edit " + @reward.name
		@form_title = "Edit " + @reward.name
		render "reward_form"
	end
	
	def update
		if @reward.update_attributes(params[:reward])
			flash[:success] = "Store item successfully updated."
			redirect_to @reward
		else
			@title = "Edit"
			@form_title = @title
			render "rewards/reward_form"
		end
	end
	
	# def destroy
		# @task.destroy
		# redirect_back_or_to @task.path
	# end
	
	private
		def admin_or_company_admin
			redirect_to(root_path) unless (current_user.admin? || current_user.company_admin?)
		end
		
		def correct_company
			if !params[:id].nil?
				@reward = Reward.find_by_id(params[:id])
				if @reward.nil?
					flash[:error] = "Could not find the requested data."
					redirect_to root_path
				elsif !current_user.admin? && @reward.company.id != current_user.company.id
					flash[:error] = "You do not have access to that data."
					redirect_to current_user
				else 
					@company = @reward.company
				end
			elsif !params[:company_id].nil?
				if !current_user.admin? && params[:company_id].to_s != current_user.company.id.to_s
					flash[:error] = "You do not have access to that data."
					redirect_to current_user
				else
					@company = Company.find_by_id(params[:company_id])
				end
			elsif !params[:reward].nil?
				if !current_user.admin? && params[:reward][:company_id].to_s != current_user.company.id.to_s
					flash[:error] = "You do not have access to that data."
					redirect_to current_user
				else
					@company = Company.find_by_id(params[:reward][:company_id])
				end
			else
				flash[:error] = "You must supply a company argument."
				redirect_to root_path
			end
		end
end