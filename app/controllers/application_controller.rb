class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  before_filter :reroute_to_landing, :except => :landing
  
  private
	def reroute_to_landing
		if Rails.env.production?
			redirect_to landing_path
		end
	end
end
