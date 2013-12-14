require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module Metabright
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)
    config.assets.enabled = true
    
    config.assets.version = '3.0'

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    
    config.action_dispatch.default_headers['X-Frame-Options'] = "ALLOWALL"

    config.i18n.load_path += Dir[Rails.root.join("config/carmen.yml")]

    config.action_mailer.default_url_options = { host: "www.metabright.com" }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.smtp_settings = {
      :address              => "smtp.mandrillapp.com",
      :port                 => 587,
      :domain               => 'www.metabright.com',
      :user_name            => 'jskirst@metabright.com',
      :password             => 'OYPyfowFxEVpbtux4ze9pg',
      :authentication       => 'plain',
      :enable_starttls_auto => true  }
  end
end
