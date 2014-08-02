source 'http://rubygems.org'
ruby '2.1.2'

gem 'rails', "4.0.2"
gem 'will_paginate'
gem 'jquery-rails'
gem 'paperclip'
gem 'aws-sdk'
gem 'pg'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
gem 'omniauth-linkedin-oauth2'
gem 'omniauth-github'
gem 'taps'
gem 'haml'
gem 'quiet_assets'
gem 'nokogiri'
gem 'carmen'
gem 'carmen-rails', git: 'https://github.com/jim/carmen-rails.git'
gem 'fb_graph'
gem 'turbolinks'
gem 'dalli'
gem 'awesome_print'
gem 'font_assets'
gem 'geocoder'
gem 'stripe', :git => 'https://github.com/stripe/stripe-ruby'
gem 'w3c_validators'
gem 'google-tag-manager-rails'
gem 'sitemap_generator'
gem 'fog'
gem 'hamster_powered', git: 'https://github.com/jskirst/hamster_powered'
gem 'exception_notification'
gem 'exception_notification-rake', '~> 0.1.0'
gem 'unf'
gem 'prawn', git: 'https://github.com/prawnpdf/prawn.git'
gem 'browser'

# add these gems to help with the transition:
gem 'protected_attributes'
gem 'activerecord-deprecated_finders'

gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'

gem 'memcachier'

group :production do
  gem 'rails_12factor'
  gem 'unicorn'
end

group :development, :test do
  gem 'faker'
end

group :development do
  gem 'thin'
	gem 'rspec-rails'
	gem 'annotate'
  gem 'better_errors'   
  gem 'binding_of_caller'
  gem 'meta_request'
  gem 'sextant'
  #gem 'sql-logging'
  #gem 'rack-mini-profiler'
  #gem 'debugger'
end

group :test do
	gem 'capybara'
	gem 'poltergeist'
	gem 'rspec-rails'
	gem 'factory_girl_rails'
	gem 'launchy'
	gem 'selenium-webdriver'
	gem 'simplecov', :require => false
  gem 'database_cleaner'
  gem 'rspec-retry'
end
