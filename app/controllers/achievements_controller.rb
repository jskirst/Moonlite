class AchievementsController < ApplicationController
	before_filter :authenticate
	before_filter :authorized_user
	
	def new
		@achievement = Achievement.new
		@title = "New achievement"
		@form_title = @title
		render "achievements/form"
	end
	
	def create
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
		@achievements = Achievement.paginate(:page => params[:page], :conditions => ["path_id = ?", @path.id])
		@title = "All achievements"
	end
	
	private
		def authorized_user
			if !params[:path_id].nil?
				@path = Path.find(params[:path_id])
				redirect_to root_path unless current_user?(@path.user)
			elsif !params[:achievement].nil? && !params[:achievement][:path_id].nil?
				@path = Path.find(params[:achievement][:path_id])
				redirect_to root_path unless current_user?(@path.user)
			else
				redirect_to root_path
			end
		end
end