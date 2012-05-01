class TasksController < ApplicationController
	before_filter :authenticate
	before_filter :has_access?
	before_filter :get_task_from_id, :only => [:edit, :update, :destroy]
	before_filter :can_edit?, :only => [:edit, :update, :destroy]
	
	def new
		@section_id = params[:section_id]
		@section = Section.find(@section_id)
		unless can_edit_path(@section.path)
			flash[:error] = "You cannot add tasks to this path."
			redirect_to root_path
			return
		end
		
		@task = Task.new
    @ca = 1
		@title = "New Question"
		
		@form_title = "New Question"
		render "tasks/task_form"
	end
	
	def create
		@section = Section.find(params[:task][:section_id])
		unless can_edit_path(@section.path)
			flash[:error] = "You cannot add tasks to this path."
			redirect_to root_path
			return
		end
		
		@task = @section.tasks.build(params[:task])
    @task.points = 10
		if @task.save
			flash[:success] = "Question created."
			if params[:commit] == "Save and New"
				redirect_to new_task_path(:section_id => @section.id)
			else
				redirect_to edit_section_path(@section, :m => "tasks")
			end
		else
			@title = "Edit Question"
			@form_title = @title
			@section_id = @section.id
			render "tasks/task_form"
		end
	end
	
	def edit
		@title = "Edit Question"
		@form_title = "Edit Question"
		
		@info_resource = InfoResource.find_by_task_id(@task.id)
    @ca = @task.correct_answer
		@section_id = @task.section_id
		
		@path = @task.section.path
		@sections = @path.sections
		render "task_form"
	end
	
	def update
		if params[:task][:section_id].to_i != @task.section.id
			old_section = @task.section
			path = old_section.path
			new_section = path.sections.find(params[:task][:section_id])
			if new_section.nil?
				flash[:error] = "The section you tried to reassign to does not belong to this path."
				redirect_to root_path
			else
				@task.section_id = new_section.id
				if @task.save
					flash[:success] = "Task successfully reasigned to section '#{new_section.name}'."
					redirect_to edit_section_path(old_section, :m => "tasks")
				else
					flash[:error] = "Could not reassign task due to unknown error. Please try again."
					@sections = path.sections
					render "tasks/task_form"
				end
			end
		elsif @task.update_attributes(params[:task])
			flash[:success] = "Question updated."
			redirect_to edit_section_path(:id => @task.section.id, :m => "tasks")
		else
			@title = "Edit Question"
			@form_title = @title
			render "tasks/task_form"
		end
	end
  
  def suggest
    @phrase = params[:id]
		logger.debug "SUGGEST: searching for phrase: '#{@phrase}'"
    @phrase = Phrase.search(@phrase.downcase)
		logger.debug "SUGGEST: search result: '#{@phrase}'"
    @associated_phrases = []
    unless @phrase.nil?
      @associated_phrases = @phrase.associated_phrases
    end
    respond_to do |format|
      format.json  
    end  
  end
	
	def destroy
		@task.destroy
    flash[:success] = "Question deleted."
		redirect_to edit_section_path(@task.section, :m => "tasks")
	end
	
	private
		def get_task_from_id
			@task = Task.find(params[:id])
			unless @task
				flash[:error] = "Task could not be found."
				redirect_to root_path
			end
		end
		
		def has_access?
			unless @enable_user_creation
				flash[:error] = "You do not have access to this functionality."
				redirect_to root_path
			end
		end
	
		def can_edit?
			unless can_edit_path(@task.path)
				flash[:error] = "You do not have access to this Path. Please contact your administrator to gain access."
				redirect_to root_path
			end
		end
end