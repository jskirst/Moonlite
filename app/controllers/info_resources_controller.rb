class InfoResourcesController < ApplicationController
	before_filter :authenticate
	before_filter :authorized_user, :only => :destroy
	
	def new
		@info_resource = InfoResource.new
		@title = "New Resource"
		@path_id = params[:path]
		@form_title = "New"
		render "info_resource_form"
	end
	
	def create
		@path = Path.find(params[:info_resource][:path_id])
		@info_resource = @path.info_resources.build(params[:info_resource])
		if @info_resource.save
			flash[:success] = "Resource created."
			redirect_to @path
		else
			@title = "New"
			@form_title = @title
			@path_id = @path.id
			render "info_resource_form"
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
		def authorized_user
			@info_resource = InfoResource.find(params[:id])
			redirect_to root_path unless current_user?(@info_resource.path.user)
		end
end