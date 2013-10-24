class Newsletters < ActionMailer::Base
  default from: "Team MetaBright <team@metabright.com>"

  def newsletter(user, newsletter, subject = "Here's what's happening on MetaBright...")
    raise "Fatal: Newsletter does not exist for today" unless File.exists? "#{Rails.root}/app/views/newsletters/#{newsletter}.html.haml"
    @user = user
    @settings_url = notification_settings_url(@user.signup_token)
    @professional_url = professional_user_url(@user.signup_token)
    return false unless @user.can_email?(:weekly)
    
    m = mail(to: @user.email, 
      from: "Team MetaBright <team@metabright.com>", 
      subject: subject,
      template_path: "newsletters",
      template_name: newsletter)
    @user.log_email(m)
    puts "Really sent mail to: #{@user.email}"
    return m
  end
end