class TasksController < ApplicationController
	before_filter :authenticate
	before_filter :has_access?
	before_filter :get_task_from_id, :only => [:edit, :update, :destroy]
	before_filter :can_edit?, :only => [:edit, :update, :destroy]
	
  respond_to :json, :html
  
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
		@answers = @task.describe_answers
    respond_to {|f| f.html { render :partial => "edit_task_form" } }
	end
	
	def create
		@section = Section.find(params[:task][:section_id])
		unless can_edit_path(@section.path)
			respond_with({ :error => "You do not have access to that object." })
		end
		
		@task = @section.tasks.new(params[:task])
		if @task.save
			respond_to do |f|
				f.html { render :partial => "task", :locals => {:task => @task } }
				f.json { render :json => @task }
			end
		else
			respond_to {|f| f.json { render :json => { :errors => @task.errors.full_messages } } }
		end
	end
	
	def update
		if @task.update_attributes(params[:task])
			respond_to do |f|
        f.html { render :partial => "task", :locals => {:task => @task} }
        f.json { render :json => @task }
      end
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
		if @task.destroy
      respond_to { |f| f.json { render :json => { :success => "Question deleted." } } }
    else
      respond_to { |f| f.json { render :json => { :errors => "Question could not be deleted." } } }
    end
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