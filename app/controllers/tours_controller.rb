class ToursController < ApplicationController
	before_filter :authenticate
  before_filter :is_enabled

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
  
  private
  
    def is_enabled
      unless current_user.company.enable_tour
        flash[:error] = "This feature is not currently enabled for your use."
        redirect_to root_path
      end
    end

end
