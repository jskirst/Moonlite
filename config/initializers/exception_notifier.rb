if Rails.env == "production"
  Metabright::Application.config.middleware.use ExceptionNotification::Rack,
    :email => {
      :email_prefix => "[Exception Notification] ",
      :sender_address => %{"notifier" <notifier@metabright.com>},
      :exception_recipients => %w{jskirst@metabright.com nsdub@metabright.com}
    }

  ExceptionNotifier::Rake.configure
end