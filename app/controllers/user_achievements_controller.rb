class UserAchievementsController < ApplicationController
	before_filter :authenticate
	
	def show
		@user_achievement = UserAchievement.find_by_id(params[:id])
		if @user_achievement.nil?
			redirect_to root_path and return
		end
    @user = @user_achievement.user
		@achievement = @user_achievement.achievement
    @path = @achievement.path
    @date = @user_achievement.created_at
		@title = @achievement.name
	end
end