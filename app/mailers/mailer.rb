class Mailer < ActionMailer::Base
  default from: "Team MetaBright <team@metabright.com>"
  
  def welcome(email)
    @user = User.find_by_email(email)
    @settings_url = notification_settings_url(@user.signup_token)
    mail(to: @user.email, from: "Jonathan Kirst <jskirst@metabright.com>", subject: "Welcome to MetaBright!")
  end
  
  def content_comment_alert(comment)
    if comment.is_a? String
      comment = SubmittedAnswer.find(comment).comments.first
    end
    @submission = comment.owner
    @user = @submission.user
    return false unless @user.can_email?(:interaction)
    
    @settings_url = notification_settings_url(@user.signup_token)
    @commenting_user = comment.user
    @action_url = submission_details_url(@submission.path.permalink, @submission)
    mail(to: @user.email, subject: "Someone just commented on your MetaBright submission")
  end
  
  def content_vote_alert(vote)
    if vote.is_a? String
      vote = SubmittedAnswer.find(vote).votes.first
    end
    @submission = vote.submitted_answer
    @user = vote.submitted_answer.user
    return unless @user.can_email?(:interaction)
    
    @settings_url = notification_settings_url(@user.signup_token)
    @voting_user = vote.user
    @action_url = submission_details_url(@submission.path.permalink, @submission)
    mail(to: @user.email, subject: "Someone voted for your MetaBright submission!")
  end
  
  def intro_drop_off(email)
    @user = User.find_by_email(email)
    return unless @user.can_email?()
    
    mail(to: @user.email, subject: "Complete your first Challenge!")
  end
  
  def contribution_unlocked(email, path)
    @user = User.find_by_email(email)
    return unless @user.can_email?(:powers)
    
    @settings_url = notification_settings_url(@user.signup_token)
    @challenge_name = path.name
    mail(to: @user.email, subject: "MetaBright Power Unlocked! Create your own MetaBright questions!")
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
