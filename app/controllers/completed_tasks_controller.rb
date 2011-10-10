class CompletedTasksController < ApplicationController
	before_filter :authenticate
	before_filter :authorized_user, :only => :destroy
	before_filter :correct_answer?, :only => :create
	
	def create	
		@completed_task = current_user.completed_tasks.build(params[:completed_task])
		if @completed_task.save
			flash[:success] = "Correct!"
			redirect_to continue_path_path :id => @completed_task.task.path
		else
			redirect_to root_path
		end
	end
	
	def destroy
		@completed_task = CompletedTask.find_by_id(params[:id])
		@path = @completed_task.task.path
		@completed_task.destroy
		redirect_to @path
	end
	
	private
		def authorized_user
			@completed_task = CompletedTask.find(params[:id])
			redirect_to root_path unless current_user?(@completed_task.user)
		end
		
		#TEST
		def correct_answer?
			task_id = params[:completed_task][:task_id]
			if task_id.nil?
				redirect_to root_path and return
			end
			
			@task = Task.find_by_id(params[:completed_task][:task_id])
			if @task.nil?
				redirect_to root_path  and return
			elsif @task.answer != params[:completed_task][:answer]
				flash[:error] = "Incorrect answer"
				redirect_to continue_path_path :id => @task.path
			end
		end
end