class Mailer < ActionMailer::Base
  default from: "Team MetaBright <team@metabright.com>"
  layout "mail"
  
  def welcome(email)
    @user = User.find_by_email(email)
    mail(to: @user.email, from: "Jonathan Kirst <jskirst@metabright.com>", subject: "Welcome to MetaBright!")
    @user.log_email
  end
  
  def content_comment_alert(comment)
    if comment.is_a? String
      comment = SubmittedAnswer.find(comment).comments.first
    end
    @submission = comment.owner
    @user = @submission.user
    @commenting_user = comment.user
    return false if @user == @commenting_user
    return false unless @user.can_email?(:interaction)
    
    @action_url = submission_details_url(@submission.path.permalink, @submission)
    mail(to: @user.email, subject: "Someone just commented on your MetaBright submission")
    @user.log_email
  end
  
  def content_vote_alert(vote)
    if vote.is_a? String
      vote = SubmittedAnswer.find(vote).votes.first
    end
    @submission = vote.owner
    @user = vote.owner.user
    @voting_user = vote.user
    return false if @user == @voting_user
    return false unless @user.can_email?(:interaction)
    
    @action_url = submission_details_url(@submission.path.permalink, @submission)
    mail(to: @user.email, subject: "Someone voted for your MetaBright submission!")
    @user.log_email
  end
  
  def intro_drop_off(email)
    @user = User.find_by_email(email)
    return false unless @user.can_email?()
    
    mail(to: @user.email, subject: "Complete your first Challenge!")
  end
  
  def contribution_unlocked(email, path)
    @user = User.find_by_email(email)
    return false unless @user.can_email?(:powers)
    
    @challenge_name = path.name
    @challenge_link = challenge_url(path.permalink, completed: true) 
    mail(to: @user.email, subject: "MetaBright Power Unlocked! Create your own MetaBright questions.")
    @user.log_email
  end
  
  def new_idea(idea)
    @idea = idea
    admins = User.joins(:user_role).where("user_roles.enable_administration = ?", true)
    mail(to: admins.first.email, subject: "[NEW IDEA] #{@idea.title}", cc: admins.collect(&:email))
  end
end
