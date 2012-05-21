class CompletedTasksController < ApplicationController
	before_filter :authenticate
	before_filter :enrolled_user?
  before_filter :post_comment
	
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
				if @enable_feedback
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