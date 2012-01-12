class CompletedTasksController < ApplicationController
	before_filter :authenticate
	before_filter :enrolled_user?
	
	def create
		resp = params[:completed_task]
		resp[:quiz_session] = resp[:quiz_session] || DateTime.now
		answer = resp[:answer]
		
		if answer.nil? || answer == ""
			status_id = 2
		elsif Integer(answer) == Integer(@task.correct_answer)
			status_id = 1
		else
			status_id = 0
		end
		
		@completed_task = current_user.completed_tasks.build(resp.merge(:status_id => status_id))		
		if @completed_task.save
			set_flash_message(status_id, answer, @task.correct_answer)
			if status_id == 1
				PointTransaction.create!({:user_id => current_user.id,
					:task_id => @completed_task.task.id, 
					:points => @completed_task.task.points,
					:status => 1})
				current_user.award_points(@completed_task.task)
			end
			redirect_to continue_path_path :id => @completed_task.task.path, 
				:max => resp[:max], 
				:count => resp[:count], 
				:quiz_session => resp[:quiz_session]
		else
			redirect_to root_path
		end
	end
	
	private
		def enrolled_user?
			if !params[:completed_task].nil? && !params[:completed_task][:task_id].nil? 
				@task = Task.find_by_id(params[:completed_task][:task_id])
				if @task.nil?
					redirect_to root_path
				else
					redirect_to root_path unless current_user.enrolled?(@task.path)
				end
			else
				redirect_to root_path
			end
		end
		
		def set_flash_message(status_id, user_answer, correct_answer)
			if status_id == 0
				flash[:error] = "Incorrect. You answered #{user_answer}. The correct answer was #{correct_answer}."
			elsif status_id == 1
				flash[:success] = "Correct!"
			else
				flash[:notice] = "Question skipped."
			end
		end
end