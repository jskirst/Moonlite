class ApplicationController < ActionController::Base
  before_filter :determine_enabled_features
	
	protect_from_forgery
  include SessionsHelper
	
	private
		def determine_enabled_features
			unless current_user.nil?
				company = current_user.company
				@enable_rewards = company.enable_company_store
				@enable_leaderboard = company.enable_leaderboard
				@enable_dashboard = company.enable_dashboard
				@enable_tour = company.enable_tour
				@enable_browsing = company.enable_browsing
				@enable_comments = company.enable_comments
				@enable_news = company.enable_news
				@enable_feedback = company.enable_feedback
				@enable_achievements = company.enable_achievements
				@enable_recommendations = company.enable_recommendations
				@enable_user_creation = company.enable_user_creation
			end
		end
end
