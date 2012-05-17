class TasksController < ApplicationController
	before_filter :authenticate
	before_filter :has_access?
	before_filter :get_task_from_id, :only => [:edit, :update, :destroy]
	before_filter :can_edit?, :only => [:edit, :update, :destroy]
	
	respond_to :json
	
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
	
	def create
		@section = Section.find(params[:task][:section_id])
		unless can_edit_path(@section.path)
			respond_with({ :error => "You do not have access to that object." })
		end
		
		@task = @section.tasks.new(params[:task])
		if @task.save
			respond_with(@task)
		else
			respond_with({ :errors => @task.errors.full_messages }, :location => nil)
		end
	end
	
	def update
		section = @task.path.sections.find(params[:task][:section_id])
		if section.nil?
			respond_to { |f| f.json { render :json => { :errors => "Section does not exist." } } }
			return
		end
		
		if @task.update_attributes(params[:task])
			respond_to { |f| f.json { render :json => @task } }
		else
			respond_to { |f| f.json { render :json => { :errors => @task.errors.full_messages } } }
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