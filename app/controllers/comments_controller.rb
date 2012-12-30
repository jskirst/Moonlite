class CommentsController < ApplicationController
  before_filter :authenticate
  
  def create
    comment = current_user.comments.new(params[:comment])
    if comment.save
      owner = comment.owner
      if owner.is_a? SubmittedAnswer
        link = submission_details_path(owner.path, owner)
        content = "#{current_user} commented on your submission."
        log_event(comment.owner.user, link, current_user.profile_pic, content)
      end
      render partial: "comment", locals: { comment: comment }
    else
      raise "No comment provided"
    end
  end

  def destroy
    comment = Comment.find_by_id(params[:id])
    raise "Access Denied" unless comment.user_id == current_user.id
    comment.destroy
    render json: { status: "success" }
  end
end
