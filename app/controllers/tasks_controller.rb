class TasksController < ApplicationController
	before_filter :authenticate, :only => [:create, :destroy, :show]
	before_filter :authorized_user, :only => :destroy
	
	def new
		@task = Task.new
		@title = "New Task"
		@path_id = params[:path]
		@form_title = "New"
		render "tasks/task_form"
	end
	
	def create
		@path = Path.find(params[:task][:path_id])
		@task = @path.tasks.build(params[:task])
		if @task.save
			flash[:success] = "Task created."
			redirect_to @path
		else
			@title = "Edit"
			@form_title = @title
			@path_id = @path.id
			render "tasks/task_form"
		end
	end
	
	def show
		@task = Task.find(params[:id])
		@title = @task.path.name
	end
	
	def edit
		@title = "Edit"
		@form_title = "New"
		@task = Task.find(params[:id])
		@path_id = @task.path_id
		render "task_form"
	end
	
	def update
		@task = Task.find(params[:id])
		if @task.update_attributes(params[:task])
			flash[:success] = "Question successfully updated."
			redirect_to @task
		else
			@title = "Edit"
			@form_title = @title
			render "tasks/task_form"
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