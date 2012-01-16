class UserAchievementsController < ApplicationController
	before_filter :authenticate
	
	def show
		@user_achievement = UserAchievement.find_by_id(params[:id])
		if @user_achievement.nil?
			redirect_to root_path and return
		end
		@achievement = @user_achievement.achievement
		@title = @achievement.name
	end
end