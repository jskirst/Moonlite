class AchievementsController < ApplicationController
	before_filter :authenticate
	before_filter :company_admin, :except => [:show]
	before_filter :get_from_id, :except => [:new, :create]
	before_filter :get_path_from_id, :only => [:new]
  before_filter :get_path_from_params, :only => [:create]
  before_filter :authorized, :except => [:show]
	before_filter :is_enabled?
	
	def new
		if @path.nil?
			flash[:error] = "No Path argument supplied."
			redirect_to root_path
		else
			@sections = @path.sections
			@achievement = Achievement.new
			@title = "New Achievement"
			render "new"
		end
	end
	
	def create
		a = params[:achievement]
    @achievement = @path.achievements.build(a)
    @sections = @path.sections
    if a[:tasks].nil?
			flash[:error] = "You did not select any tasks or sections to include as criteria for unlocking this achievement."
			render "new"
    else
      @achievement.criteria = a[:tasks].map { |id, state| id }.join(",")
      if @achievement.save
        flash[:success] = "Achievement created."
        redirect_to edit_path_path(@path, :m => "achievements")
      else
        @title = "New achievement"
        render "new"
      end
    end
	end
  
  def show
    @user_achievements = @achievement.user_achievements
  end
	
	def edit
    task_ids = @achievement.criteria
    @tasks = Task.find(:all, :conditions => ["tasks.id IN (#{task_ids})"])
		@title = "Edit Achievement"
	end
	
	def update
		if @achievement.update_attributes(params[:achievement])
			flash[:success] = "Changes saved."
			redirect_to edit_path_path(@path, :m => "achievements")
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
		def is_enabled?
			unless @enable_achievements
				flash[:error] = "This functionality has not been enabled for you."
				redirect_to root_path
			end
		end
	
		def get_from_id
      @achievement = Achievement.find_by_id(params[:id])
			if @achievement.nil?
				flash[:error] = "No record found for the argument supplied."
				redirect_to root_path and return
			end
      @path = @achievement.path
		end
    
    def get_path_from_id
			unless @path = Path.find_by_id(params[:path_id])
				flash[:error] = "No record found for the argument supplied."
				redirect_to root_path and return
			end
		end
    
    def get_path_from_params
			unless @path = Path.find_by_id(params[:achievement][:path_id])
				flash[:error] = "No record found for the argument supplied."
				redirect_to root_path and return
			end
		end
    
    def authorized
      unless @path.company_id == current_user.company_id
        flash[:error] = "You are not authorized to access that data."
        redirect_to signin_path and return
      end
    end
end