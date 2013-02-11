class Newsletters < ActionMailer::Base
  default from: "Team MetaBright <team@metabright.com>"

  def newsletter(email)
    @user = User.find_by_email(email)
    @settings_url = notification_settings_url(@user.signup_token)
    return false unless @user.can_email?(:weekly)
    
    mail(to: @user.email, 
      from: "Team MetaBright <team@metabright.com>", 
      subject: "MetaBright Newsletter for #{Date.today.strftime("%A, %B %Y")}",
      template_path: "newsletters",
      template_name: "newsletter_#{Time.now.strftime("%m%d%Y")}")
    @user.log_email
  end
end