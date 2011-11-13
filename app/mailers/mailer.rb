class Mailer < ActionMailer::Base
	default :from => "registration@projectmoonlite.com"

	def welcome(details)
		@user_email = details[:email]
		@accept_url = "http://localhost:3000/users/#{details[:token1]}/accept"
		mail(:to => details[:email], :subject => "Hello World")
	end
end
