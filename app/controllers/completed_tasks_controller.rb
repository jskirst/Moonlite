class CompletedTasksController < ApplicationController
	before_filter :authenticate
	before_filter :enrolled_user?
  before_filter :post_comment
	
	def create
    resp = params[:completed_task]
		status_id = (Integer(resp[:answer]) == Integer(@task.correct_answer) ? 1 : 0)
		@completed_task = current_user.completed_tasks.build(resp.merge(:status_id => status_id))
		if @completed_task.save
			if status_id == 1
        points = 10
        if params[:listless] == true
          streak = @task.section.user_streak(current_user)
          streak -= 1 unless streak == 0
          points += streak
        end
        achievement = current_user.award_points_and_achievements(@task, points)
        if achievement
          flash[:success] = "Congrats! You unlocked the #{achievement.name} achievement!"
        end
			end
			redirect_to continue_section_path :id => @completed_task.task.section
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
    
    def post_comment
      if params[:commit] == "Post Comment"
        @comment = current_user.comments.new(params[:comment])
        if @comment.save
          flash[:success] = "Comment added."
        else
          flash[:error] = "There was an error when saving your comment. Please try again."
        end
        redirect_to continue_section_path :id => @comment.task.section, :quiz_session => params[:completed_task][:quiz_session], :comments_on => "on"
        return
      end
    end
end