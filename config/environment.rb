# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Metabright::Application.initialize!

ActionMailer::Base.smtp_settings = { 
	:enable_starttls_auto => true,
	:address => "smtp.sendgrid.net",
	:domain => "metabright.com",
	:port => 587, 
	:user_name => "metabright-production", 
	:password => "projectmoonlite",
	:authentication => :plain
}
