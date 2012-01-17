class ToursController < ApplicationController

	def index
		render "choose"
	end

	def admin_tour
		@page = params[:id].to_i
		@final_page = 8
	end
	
	def user_tour
		@page = params[:id].to_i
		@final_page = 8
	end

end
