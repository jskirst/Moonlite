class CompletedTasksController < ApplicationController
	before_filter :authenticate
	before_filter :enrolled_user?
  before_filter :post_comment
	
	def create
		previous_task = current_user.completed_tasks.last
		last_answer_date = previous_task.created_at unless previous_task.nil?

    resp = params[:completed_task]
		unless resp[:text_answer].nil?
			status_id = @task.is_correct?(resp[:text_answer], "text") ? 1 : 0
		else
			status_id = @task.is_correct?(resp[:answer], "multiple") ?  1 : 0
		end
		@completed_task = current_user.completed_tasks.build(resp.merge(:status_id => status_id))
		
		streak = @task.section.user_streak(current_user)
		if status_id == 1
			points = 10
			if params[:listless] == "true"				
				unless streak < 1
					sixty_seconds_ago = 60.seconds.ago
					logger.debug last_answer_date
					logger.debug sixty_seconds_ago
					if last_answer_date > sixty_seconds_ago
						points += streak
					end
				end
			end
			@completed_task.points_awarded = points
			@completed_task.save
			achievement = current_user.award_points_and_achievements(@task, points)
		else
			@completed_task.points_awarded = 0
			@completed_task.save
		end
		redirect_to continue_section_path :id => @completed_task.task.section, :p => status_id
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
    
    def post_comment
      if params[:commit] == "Post Comment"
				if current_user.company.enable_feedback
					@comment = current_user.comments.new(params[:comment])
					if @comment.save
						flash[:success] = "Comment added."
					else
						flash[:error] = "There was an error when saving your comment. Please try again."
					end
					redirect_to continue_section_path :id => @comment.task.section, :quiz_session => params[:completed_task][:quiz_session], :comments_on => "on"
				else
					redirect_to root_path
				end
      end
    end
end