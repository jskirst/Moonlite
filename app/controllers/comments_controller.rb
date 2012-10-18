class CommentsController < ApplicationController
  before_filter :authenticate
  
  def create
    @comment = current_user.comments.new(params[:comment])
    if @comment.save
      render partial: "comment", locals: { comment: @comment }
    else
      raise "No comment provided"
    end
  end

  def destroy
    @comment = Comment.find_by_id(params[:id])
    raise "Cannot delete what you do not own." unless @comment.user == current_user
    @comment.destroy
    render json: { status: "success" }
  end
end
