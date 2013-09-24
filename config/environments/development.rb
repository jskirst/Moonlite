# Amazon S3
ENV['AWS_ACCESS_KEY_ID'] 			= "AKIAJQGM5NKT235MHP3A"
ENV['AWS_SECRET_ACCESS_KEY']  = "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"
ENV['S3_BUCKET_NAME']					=	"moonlite-dev"

Metabright::Application.configure do
	# Settings specified here will take precedence over those in config/environment.rb

	# In the development environment your application's code is reloaded on
	# every request.  This slows down response time but is perfect for development
	# since you don't have to restart the webserver when you make code changes.
	config.cache_classes = false

  config.eager_load = true

	# Show full error reports and disable caching
	config.consider_all_requests_local       = true
	config.action_controller.perform_caching = false
	config.cache_store = :dalli_store

	# Care if the mailer can't send
	config.action_mailer.raise_delivery_errors = true
	config.action_mailer.delivery_method = :smtp
	ActionMailer::Base.delivery_method = :smtp

	# Print deprecation notices to the Rails logger
	config.active_support.deprecation = :log

	# Only use best-standards-support built into browsers
	config.action_dispatch.best_standards_support = :builtin
	config.action_mailer.default_url_options = { host: "localhost:3000" }
	
	#SqlLogging::Statistics.top_sql_queries = 50
	
	config.font_assets.origin = 'http://localhost:3000'
  
  # Google Tag Manager
  GoogleTagManager.gtm_id = "GTM-K6NTXR"
  
end