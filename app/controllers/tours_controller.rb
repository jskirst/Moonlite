class ToursController < ApplicationController
	before_filter :authenticate

	def index
		if current_user.company_admin?
			render "choose"
		else
			redirect_to user_tour_tour_path(1)
		end
	end

	def admin_tour
		if current_user.company_admin?
			@page = params[:id].to_i
			@final_page = 8
			@title = "Moonlite Admin Tour"
		else
			redirect_to user_tour_tour_path(1)
		end
	end
	
	def user_tour
		@title = "Moonlite Tour"
		@page = params[:id].to_i
		@final_page = 4
	end

end
