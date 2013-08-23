class GroupMailer < ActionMailer::Base
  default from: "Team MetaBright <team@metabright.com>"
  layout "mail"
  
  def welcome(group)
    @group = group
    @user = group.users.first
    if @group.users.count == 1
      @u = "user"
    else
      @u = "users"
    end
    m = mail(to: @user.email, subject: "Welcome to MetaBright!")
  end
  
  def submission(evaluation_enrollment)
    @evaluation_enrollment = evaluation_enrollment
    @evaluation = @evaluation_enrollment.evaluation
    @user = @evaluation_enrollment.evaluation.user
    m = mail(to: @user.email, subject: "#{@user.name} has just completed your evaluation")
  end
  
  def invite(email, group, url)
    @group = group
    @url = url
    m = mail(to: email, subject: "You've been invited to join the #{group.name} account on MetaBright", bcc: "jonathan@metabright.com")
  end
  
  def send_email(email)
    @content = email.body
    @content = @content.gsub("@name", email.to_name)
    m = mail(to: email.to_email, subject: email.subject, from: email.from)
  end
end
    