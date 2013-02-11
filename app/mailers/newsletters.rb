class Newsletters < ActionMailer::Base
  default from: "Team MetaBright <team@metabright.com>"

  def newsletter(email, newsletter)
    raise "Fatal: Newsletter does not exist for today" unless File.exists? "#{Rails.root}/app/views/newsletters/#{newsletter}.html.haml"
    @user = User.find_by_email(email)
    @settings_url = notification_settings_url(@user.signup_token)
    return false unless @user.can_email?(:weekly)
    
    mail(to: @user.email, 
      from: "Team MetaBright <team@metabright.com>", 
      subject: "Here's what's happening on MetaBright...",
      template_path: "newsletters",
      template_name: newsletter)
    @user.log_email
  end
end