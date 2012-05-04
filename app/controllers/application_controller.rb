class ApplicationController < ActionController::Base
  before_filter :determine_enabled_features
	
	protect_from_forgery
  include SessionsHelper
	
	private
		def determine_enabled_features
			unless current_user.nil?
				roll = current_user.user_roll
				@is_consumer = (current_user.company_id == 1)
				@enable_administration = roll.enable_administration
				@enable_rewards = roll.enable_company_store
				@enable_leaderboard = roll.enable_leaderboard
				@enable_dashboard = roll.enable_dashboard
				@enable_tour = roll.enable_tour
				@enable_browsing = roll.enable_browsing
				@enable_comments = roll.enable_comments
				@enable_news = roll.enable_news
				@enable_feedback = roll.enable_feedback
				@enable_achievements = roll.enable_achievements
				@enable_recommendations = roll.enable_recommendations
				@enable_printer_friendly = roll.enable_printer_friendly
				@enable_user_creation = roll.enable_user_creation
				@enable_auto_enroll = roll.enable_auto_enroll
				@enable_one_signup = roll.enable_one_signup
				@enable_collaboration = roll.enable_collaboration
				@enable_auto_generate = roll.enable_auto_generate
			end
		end
end
