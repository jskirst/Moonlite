class InfoResourcesController < ApplicationController
  before_filter :authenticate
  before_filter :has_access?
  
  def new
    @task = Task.find(params[:task_id])
    if @task.path.company == current_user.company
      @info_resource = InfoResource.new(:task_id => params[:task_id])
      @title = "New Image"
    else
      flash[:error] = "You do not have access to that data. Your actions have been reported."
      redirect_to root_path
    end
  end
  
  def create
    @task = Task.find(params[:info_resource][:task_id])
    if @task.path.company == current_user.company
      @info_resource = InfoResource.new(params[:info_resource])
      if @info_resource.save
        flash[:success] = "Image added."
        redirect_to edit_path_path(@info_resource.task.path)
      else
        @title = "New"
        render "new"
      end
    else
      flash[:error] = "You do not have access to that data. Your actions have been reported."
      redirect_to root_path
    end
  end
  
  def destroy
    @info_resource = InfoResource.find(params[:id])
    if @info_resource.section && @info_resource.section.path.company == current_user.company
      @info_resource.destroy
      flash[:success] = "Resource deleted."
      redirect_to edit_path_path(@info_resource.section.path)
    elsif @info_resource.task && @info_resource.task.section.path.company == current_user.company
      @info_resource.destroy
      flash[:success] = "Resource deleted."
      redirect_to edit_path_path(@info_resource.task.path)
    else
      flash[:error] = "You do not have access to that data. Your actions have been reported."
      redirect_to root_path
    end
  end
  
  private
    def has_access?
      redirect_to root_path unless @enable_administration || @enable_user_creation
    end
end