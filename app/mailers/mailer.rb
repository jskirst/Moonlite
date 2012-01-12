class Mailer < ActionMailer::Base
	default :from => "registration@projectmoonlite.com"

	def welcome(details)
		@user_email = details[:email]
		@accept_url = "http://moonlite.heroku.com/users/#{details[:token1]}/accept"
		mail(:to => details[:email], :subject => "Hello World")
	end
	
	def invitation_alert(email)
		@email = email
		mail(:to => "jskirst@gmail.com", :subject => "Invitation Alert")
	end
end
