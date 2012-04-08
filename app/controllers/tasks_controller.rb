class TasksController < ApplicationController
	before_filter :authenticate
	before_filter :company_admin
	
	def new
		@task = Task.new
    @ca = 1
		@title = "New Task"
		@section_id = params[:section_id]
		@form_title = "New Task"
		render "tasks/task_form"
	end
	
	def create
		@section = Section.find(params[:task][:section_id])
		@task = @section.tasks.build(params[:task])
    @task.points = 10
		if @task.save
			flash[:success] = "Task created."
			if params[:commit] == "Save and New"
				redirect_to new_task_path(:section_id => @section.id)
			else
				redirect_to edit_section_path(@section, :m => "tasks")
			end
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
		@title = "Edit Task"
		@form_title = "Edit Task"
		@task = Task.find(params[:id])
    @info_resource = InfoResource.find_by_task_id(@task.id)
    @ca = @task.correct_answer
		@section_id = @task.section_id
		render "task_form"
	end
	
	def update
		@task = Task.find(params[:id])
		if @task.update_attributes(params[:task])
			flash[:success] = "Task updated."
			redirect_to edit_section_path(:id => @task.section.id, :m => "tasks")
		else
			@title = "Edit"
			@form_title = @title
			render "tasks/task_form"
		end
	end
  
  def suggest
    phrase = params[:id]
    phrase = Phrase.find_by_content(phrase.downcase)
    @associated_phrases = []
    unless phrase.nil?
      @associated_phrases = phrase.associated_phrases
    end
    respond_to do |format|
      format.json  
    end  
  end
	
	def destroy
		@task = Task.find(params[:id])
		@task.destroy
    flash[:success] = "Task deleted."
		redirect_to edit_section_path(@task.section, :m => "tasks")
	end
end