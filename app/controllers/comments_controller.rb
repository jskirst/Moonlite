class CommentsController < ApplicationController
  before_filter :authenticate
  
  def create
    comment = current_user.comments.new(params[:comment])
    if comment.save
      owner = comment.owner
      if owner.is_a? SubmittedAnswer
        owner.update_attribute(:has_comments, true) if owner.has_comments == false
        submission_user = comment.owner.user
        link = submission_details_path(owner.path.permalink, owner)
        alerted_users = []
        comment.owner.comments.each do |c|
          if c.user != current_user and c.user != submission_user
            next if alerted_users.include?(c.user)
            alerted_users << c.user
            UserEvent.log_event(c.user, "#{current_user} replied to your comment on a submission.", current_user, link, current_user.picture)
          end
        end
        content = "#{current_user} commented on your submission."
        UserEvent.log_event(submission_user, "#{current_user} commented on your submission.", current_user, link, current_user.picture)
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
