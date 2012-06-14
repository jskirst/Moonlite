class Mailer < ActionMailer::Base
  default :from => "registration@projectmoonlite.com"

  def welcome(details)
    @user_email = details[:email]
    @accept_url = details[:signup_link]
    mail(:to => details[:email], :subject => "Welcome to MetaBright!")
  end
  
  def reset(details)
    @user_email = details[:email]
    if Rails.env.production?
      @reset_url = "http://www.metabright.com/users/#{details[:token1]}/request_reset"
    else
      @reset_url = "http://localhost:3000/users/#{details[:token1]}/request_reset"
    end
    mail(:to => details[:email], :subject => "Password reset")
  end
  
  def invitation_alert(email)
    @email = email
    mail(:to => "jskirst@gmail.com", :subject => "Invitation Alert")
  end
end
