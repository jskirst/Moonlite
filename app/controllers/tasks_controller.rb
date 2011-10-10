class TasksController < ApplicationController
	before_filter :authenticate, :only => [:create, :destroy, :show]
	before_filter :authorized_user, :only => :destroy
	
	def new
		@task = Task.new
		@title = "New Task"
		@path_id = params[:path]
	end
	
	def create
		@path = Path.find(params[:task][:path_id])
		@task = @path.tasks.build(params[:task])
		if @task.save
			flash[:success] = "Task created."
			redirect_to @path
		else
			@path_id = @path.id
			render 'new'
		end
	end
	
	def show
		@task = Task.find(params[:id])
		@title = @task.path.name
	end
	
	def edit
		@title = "Edit"
		@task = Task.find(params[:id])
	end
	
	def update
		@task = Task.find(params[:id])
		if @task.update_attributes(params[:task])
			flash[:success] = "Question successfully updated."
			redirect_to @task
		else
			@title = "Edit"
			render 'edit'
		end
	end
	
	def destroy
		@task.destroy
		redirect_back_or_to @task.path
	end
	
	private
		def authorized_user
			@task = Task.find(params[:id])
			redirect_to root_path unless current_user?(@task.path.user)
		end
end