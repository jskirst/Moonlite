class CommentsController < ApplicationController
  before_filter :authenticate
  before_filter :get_comment_from_id, :only => [:destroy]
  
  def create
    @comment = current_user.comments.new(params[:comment])
    if @comment.save
      flash[:success] = "Comment added."
      redirect_back_or_to root_path
    else
      flash[:error] = "There was an error when saving your comment. Please try again."
      redirect_back_or_to root_path
    end
    
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
end
