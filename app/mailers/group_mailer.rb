class GroupMailer < ActionMailer::Base
  default from: "Team MetaBright <team@metabright.com>"
  layout "mail"
  
  def signup(group)
    @group = group
    @user = group.users.first
    m = mail(to: @user.email, subject: "Welcome to MetaBright!")
  end
  
  def submission(evaluation_enrollment)
    @evaluation_enrollment = evaluation_enrollment
    @evaluation = @evaluation_enrollment.evaluation
    @user = @evaluation_enrollment.user
    m = mail(to: @user.email, subject: "#{@user.name} has just completed your evaluation")
  end
  
  def invite(email, group, url)
    @group = group
    @url = url
    m = mail(to: email, subject: "You've been invited to join the #{group.name} account on MetaBright")
  end
end
    