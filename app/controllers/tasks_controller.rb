class TasksController < ApplicationController
	before_filter :authenticate
	before_filter :company_admin
	
	def new
		@task = Task.new
		@title = "New Question"
		@section_id = params[:section]
		@form_title = "New Question"
		render "tasks/task_form"
	end
	
	def create
		@section = Section.find(params[:task][:section_id])
		@task = @section.tasks.build(params[:task])
		if @task.save
			flash[:success] = "Task created."
			redirect_to @section
		else
			@title = "Edit"
			@form_title = @title
			@section_id = @section.id
			render "tasks/task_form"
		end
	end
	
	def show
		@task = Task.find(params[:id])
		@title = @task.section.name
	end
	
	def edit
		@title = "Edit Question"
		@form_title = "Edit Question"
		@task = Task.find(params[:id])
		@section_id = @task.section_id
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
		redirect_back_or_to @task.section
	end
end