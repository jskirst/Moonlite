class AchievementsController < ApplicationController
	before_filter :authenticate
	before_filter :company_admin
	
	def new
		@path = Path.find_by_id(params[:path_id])
		@achievement = Achievement.new
		@title = "New achievement"
		@form_title = @title
		render "achievements/form"
	end
	
	def create
		@path = Path.find_by_id(params[:achievement][:path_id])
		@achievement = @path.achievements.build(params[:achievement])
		if @achievement.save
			flash[:success] = "Achievement created."
			redirect_to @path
		else
			@title = "New achievement"
			@form_title = @title
			render "achievements/form"
		end
	end
	
	def index
		@path = Path.find_by_id(params[:path_id])
		@achievements = Achievement.paginate(:page => params[:page], :conditions => ["path_id = ?", @path.id])
		@title = "All achievements"
	end
end