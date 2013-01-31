class Mailer < ActionMailer::Base
  default from: "Team Metabright <team@metabright.com>"
  
  def welcome(email)
    @user = User.find_by_email(email)
    @settings_url = notification_settings_url(@user.signup_token)
    mail(to: @user.email, from: "Jonathan Kirst <jskirst@metabright.com>", subject: "Welcome to MetaBright!")
  end
  
  def content_comment_alert(comment)
    @settings_url = notification_settings_url(@user.signup_token)
    if comment.is_a? String
      comment = SubmittedAnswer.find(comment).comments.first
    end
    @submission = comment.owner
    @user = @submission.user
    @commenting_user = comment.user
    @action_url = submission_details_url(@submission.path, @submission)
    mail(to: @user.email, subject: "New comment on your MetaBright submission")
  end
  
  def content_vote_alert(vote)
    @settings_url = notification_settings_url(@user.signup_token)
    if vote.is_a? String
      vote = SubmittedAnswer.find(vote).votes.first
    end
    @submission = vote.submitted_answer
    @user = vote.submitted_answer.user
    @voting_user = vote.user
    @action_url = submission_details_url(@submission.path, @submission)
    mail(to: @user.email, subject: "New vote for your MetaBright submission")
  end
  
  def intro_drop_off(email)
    @user = User.find_by_email(email)
    mail(to: @user.email, subject: "Complete your first Challenge!")
  end
  
  def contribution_unlocked(email, path)
    @settings_url = notification_settings_url(@user.signup_token)
    @challenge_name = path.name
    mail(to: @user.email, subject: "Metabright Power Unlocked! Create your own MetaBright CR's!")
  end
  
  # def section_unlock(email)
    # @challenge_name 
    # @section_name 
    # @challenge_link 
    # @section_link 
  # end
#   
  # def challenge_unlock(email)
    # @persona_name 
    # @challenge_name
    # @challenge_link 
  # end
end
