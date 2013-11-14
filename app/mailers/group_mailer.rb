class GroupMailer < ActionMailer::Base
  default from: "Team MetaBright <team@metabright.com>"
  layout "mail"
  
  def welcome(group)
    @group = group
    @user = group.users.first
    if @group.users.count == 1
      @u = "admin"
    else
      @u = "admins"
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
    @user = User.where(email: email.to_email).first
    @settings_url = notifications_user_url(@user.signup_token)
    if email.body.include?("!!!")
      @content = render :inline => email.body, :type => 'haml', layout: false
    else
      @content = render :inline => email.body, :type => 'html', layout: false
    end
    m = mail(to: email.to_email, subject: email.subject, from: email.from, body: @content.html_safe)
  end
end
    