class RewardsController < ApplicationController
	before_filter :authenticate
	before_filter :company_admin, :except => [:show, :index, :review, :purchase]
	before_filter :is_enabled
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
			flash[:success] = "Reward created."
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
	
	def review
		@title = "Confirm purchase"
	end
	
	def purchase
		if current_user.available_points >= @reward.points
			current_user.debit_points(@reward.points)
			UserTransaction.create!({:user_id => current_user.id,
					:task_id => nil,
					:reward_id => @reward.id,
					:amount => @reward.points,
					:status => 0})			
			@title = "Purchase successful"
			flash[:success] = "Purchase successful. Enjoy!."
		else
			flash[:info] = "You do not have enough points to purchase that item. Sorry!"
			redirect_to review_reward_path(@reward)
		end
	end
	
	def destroy
		@reward.destroy
		flash[:success] = "Deleted successfully."
		redirect_to rewards_path(:company_id => @company.id)
	end
	
	private
		def is_enabled
			if !current_user.company.enable_company_store
				flash[:error] = "The Company Store has been disabled for your account."
				redirect_to root_path
			end
		end
	
		def correct_company
			if !params[:id].nil?
				@reward = Reward.find_by_id(params[:id])
				if @reward.nil?
					flash[:error] = "Could not find the reward data."
					redirect_to root_path
				elsif @reward.company.id != current_user.company.id
					flash[:error] = "You do not have access to that data."
					redirect_to current_user
				else 
					@company = @reward.company
				end
			elsif !params[:reward].nil?
				if params[:reward][:company_id].to_s != current_user.company.id.to_s
					flash[:error] = "You do not have access to that data."
					redirect_to current_user
				else
					@company = Company.find_by_id(params[:reward][:company_id])
				end
			else
				@company = current_user.company
			end
		end
end