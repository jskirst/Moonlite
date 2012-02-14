class CommentsController < ApplicationController
  before_filter :authenticate
  before_filter :get_comment_from_id, :only => [:destroy]
  before_filter :get_task_from_comment, :only => [:create]
  before_filter :verify_enrollment
  before_filter :verify_ownership, :only => [:destroy]
  
  def create
    @comment = current_user.comments.new(params[:comment])
    if @comment.save
      flash[:success] = "Comment added."
    else
      flash[:error] = "There was an error when saving your comment. Please try again."
    end
    redirect_to @comment.task
  end

  def destroy
    @comment.destroy
    redirect_to @comment.task
  end
  
  private
    def get_comment_from_id
      unless params[:id].nil?
        @comment = Comment.find_by_id(params[:id])
      end
      
      if @comment.nil?
        flash[:error] = "Could not find the comment you were looking for."
        redirect_to root_path
      end
      @task = @comment.task
    end
    
    def get_task_from_comment
      if params[:comment].nil? || params[:comment][:task_id].nil?
        flash[:error] = "Bad arguments for task."
        redirect_to root_path and return
      else
        @task = Task.find_by_id(params[:comment][:task_id])
      end
      
      if @task.nil?
        flash[:error] = "Could not find the comment you were looking for."
        redirect_to root_path
      end
    end
    
    def verify_enrollment
      unless current_user.enrolled?(@task.path)
        flash[:error] = "You must be enrolled in this path to comment on it."
        redirect_to root_path
      end
    end
    
    def verify_ownership
      unless current_user == @comment.user
        flash[:error] = "You do not have the ability to delete this comment."
        redirect_to root_path
      end
    end
end
