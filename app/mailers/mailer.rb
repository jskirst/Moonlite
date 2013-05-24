class Mailer < ActionMailer::Base
  default from: "Team MetaBright <team@metabright.com>"
  layout "mail"
  
  def welcome(email)
    @user = User.find_by_email(email)
    mail(to: @user.email, from: "Jonathan Kirst <jskirst@metabright.com>", subject: "Welcome to MetaBright!")
    @user.log_email
  end
  
  def study_guide(email)
    @user = User.find_by_email(email)
    mail(to: @user.email, subject: "Your personalized MetaBright study guide!")
    @user.log_email
  end
  
  def password_reset(user)
    @user = user
    @url = finish_reset_url(t: @user.signup_token)
    mail(to: @user.email, subject: "Password reset for MetaBright")
    @user.log_email
  end
  
  def content_comment_alert(comment)
    @submission = comment.owner
    @user = @submission.user
    @commenting_user = comment.user
    return false if @user == @commenting_user
    return false unless @user.can_email?(:interaction)
    
    @action_url = submission_details_url(@submission.path.permalink, @submission)
    mail(to: @user.email, subject: "#{@commenting_user.name} just commented on your MetaBright submission")
    @user.log_email
  end
  
  def comment_reply_alert(comment, commenting_user, user)
    @comment = comment
    @submission = comment.owner
    @commenting_user = commenting_user
    @user = user
    return false if @commenting_user == @user
    return false if @comment.user == @user
    return false unless @user.can_email?(:interaction)
    
    @action_url = submission_details_url(@submission.path.permalink, @submission)
    mail(to: @user.email, subject: "#{@commenting_user.name} just replied to your comment on MetaBright")
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
    mail(to: @user.email, subject: "#{@voting_user.name} just voted for your MetaBright submission!")
    @user.log_email
  end
  
  def content_sub_alert(subscription)
    @followed_user = subscription.followed
    @user = @followed_user
    @follower_user = subscription.follower
    
    return false unless @followed_user.can_email?(:interaction)
    
    @action_url = profile_url(@follower_user.username)
    @follow_url = follow_user_url(@follower_user.username)
    mail(to: @followed_user.email, subject: "#{@follower_user.name} is now following you!")
    @followed_user.log_email
  end
  
  def visit_alert(user, visits)
    @user = user
    return false unless @user.can_email?(:interaction)
    
    @visits = visits
    people = visits.size > 1 ? "#{visits.size} people" : "One person"
    mail(to: @user.email, subject: "#{people} viewed your profile on MetaBright!", message: "Blank")
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
    @challenge_link = challenge_url(path.permalink, c: true) 
    mail(to: @user.email, subject: "MetaBright Power Unlocked! Create your own MetaBright questions.")
    @user.log_email
  end
  
  def new_idea(idea)
    @idea = idea
    admins = User.joins(:user_role).where("user_roles.enable_administration = ? and is_fake_user = ? and is_test_user = ?", true, false, false)
    mail(to: admins.first.email, subject: "[NEW IDEA] #{@idea.title}", cc: admins.collect(&:email))
  end
  
  def opportunity(opp)
    @opp = opp
    mail(to: "team@metabright.com", subject: "[EMPLOYER REQUEST] #{Opportunity::PRODUCTS[opp.product]}")
  end
end
