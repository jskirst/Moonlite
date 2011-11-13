# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
SampleApp::Application.initialize!

ActionMailer::Base.smtp_settings = { 
	:enable_starttls_auto => true,
	:address => "smtp.gmail.com",
	:domain => "projectmoonlite.com",
	:port => 587, 
	:user_name => "sarge@projectmoonlite.com", 
	:password => "terrancj",
	:authentication => :plain
}

