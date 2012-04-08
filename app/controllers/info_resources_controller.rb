class InfoResourcesController < ApplicationController
	before_filter :authenticate
	before_filter :get_parent_type_and_id, :only => :new
  
	def new
		@info_resource = InfoResource.new
		@title = "New Resource"
	end
	
	def create
		@info_resource = InfoResource.new(params[:info_resource])
		if @info_resource.save
			flash[:success] = "Resource created."
      redirect_to edit_section_path(@info_resource.task.section, :m => "tasks")
		else
			@title = "New"
      get_parent_type_and_id
			unless @parent_type.nil?
        render "new"
      end
		end
	end
	
	def show
		@info_resource = InfoResource.find(params[:id])
		@title = @info_resource.path.name
	end
	
	def edit
		@title = "Edit"
		@form_title = "Edit"
		@info_resource = InfoResource.find(params[:id])
		@path_id = @info_resource.path_id
		render "info_resource_form"
	end
	
	def update
		@info_resource = InfoResource.find(params[:id])
		if @info_resource.update_attributes(params[:info_resource])
			flash[:success] = "Question successfully updated."
			redirect_to @info_resource
		else
			@title = "Edit"
			@form_title = @title
			render "info_resource_form"
		end
	end
	
	def destroy
		@info_resource.destroy
		redirect_back_or_to @info_resource.path
	end
	
	private
    def get_parent_type_and_id
      if params[:path_id] || (!params[:info_resource].nil? && params[:info_resource][:path_id])
        @parent_id = params[:path_id]
        @parent_type = "path"
      elsif params[:section_id] || (!params[:info_resource].nil? && params[:info_resource][:section_id])
        @parent_id = params[:section_id]
        @parent_type = "section"
      elsif params[:task_id] || (!params[:info_resource].nil? && params[:info_resource][:task_id])
        @parent_id = params[:task_id]
        @parent_type = "task"
      else
        flash[:error] = "Invalid path/section/task id. Must provide at least one."
        redirect_to root_path
      end
    end
end