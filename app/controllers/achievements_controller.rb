class AchievementsController < ApplicationController
	before_filter :authenticate
	before_filter :company_admin
	before_filter :get_from_id, :except => [:new, :create]
	
	def new
		@path = Path.find_by_id(params[:path_id])
		if @path.nil?
			flash[:error] = "No Path argument supplied."
			redirect_to root_path
		else
			@achievement = Achievement.new
			@title = "New Achievement"
		end
	end
	
	def create
		@path = Path.find_by_id(params[:achievement][:path_id])
		@achievement = @path.achievements.build(params[:achievement])
		if @achievement.save
			flash[:success] = "Achievement created."
			redirect_to edit_path_path(@path, :m => "achievements")
		else
			@title = "New achievement"
			render "new"
		end
	end
	
	def show
		@title = @achievement.name
		@path = @achievement.path
	end
	
	def edit
		@path = @achievement.path
		@title = "Edit Achievement"
	end
	
	def update
		if @achievement.update_attributes(params[:path])
			flash[:success] = "Changes saved."
			redirect_to @achievement
		else
			@title = "Edit Achievement"
			render 'edit'
		end
	end
	
	def destroy
		@achievement.destroy
		flash[:success] = "Achiement successfully deleted."
		redirect_to edit_path_path(@achievement.path, :m => "achievements")
	end
	
	private
		def get_from_id
			if !@achievement = Achievement.find_by_id(params[:id])
				flash[:error] = "No record found for the argument supplied."
				redirect_to root_path and return
			end
		end
end