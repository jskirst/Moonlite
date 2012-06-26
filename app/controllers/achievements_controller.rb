class AchievementsController < ApplicationController
  before_filter :authenticate
  before_filter :company_admin, :except => [:show]
  before_filter :get_from_id, :except => [:new, :create, :index]
  before_filter :authorized, :except => [:show]
  
  def new
    @categories = current_user.company.categories.includes(:paths)
    @achievement = Achievement.new
    @title = "New Achievement"
    render "new"
  end
  
  def create
    a = params[:achievement]
    @achievement = current_user.company.achievements.build(a)
    if a[:paths].nil?
      flash[:error] = "You did not select any #{name_for_paths.pluralize} to include as criteria for unlocking this achievement."
      redirect_to new_achievement_path
    else
      criteria = a[:paths].collect { |id, state| id }
      if @achievement.save
        flash[:success] = "Achievement created."
        criteria.each do |c|
          @achievement.path_achievements.create!(:path_id => c)
        end
        redirect_to achievements_path
      else
        @categories = current_user.company.categories.includes(:paths)
        @title = "New achievement"
        render "new"
      end
    end
  end
  
  def show
    @user_achievements = @achievement.user_achievements
  end
  
  def index
    @achievements = current_user.company.achievements
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
    flash[:success] = "Achievement successfully deleted."
    redirect_to achievements_path
  end
  
  private
    def get_from_id
      @achievement = Achievement.find_by_id(params[:id])
      if @achievement.nil?
        flash[:error] = "No record found for the argument supplied."
        redirect_to root_path and return
      end
    end
   
    def authorized
      unless @enable_administration
        flash[:error] = "You are not authorized to access that data."
        redirect_to root_path and return
      end
    end
end