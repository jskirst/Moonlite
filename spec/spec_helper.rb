ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'database_cleaner'
require 'rspec/retry'

UPLOAD_FILE_PATH = File.expand_path("../fixtures/files/test.pdf", __FILE__)
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.verbose_retry = true
  config.default_retry_count = 3
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  # config.order = "random"
  
  config.include Capybara::DSL
  config.include RequestsHelper
  config.include(MailerMacros)
  
  Capybara.register_driver :firefox do |app|
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['webdriver.load.strategy'] = 'unstable'
    Capybara::Selenium::Driver.new(app, :browser => :firefox, profile: profile)
  end
  
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, { timeout: 30, phantomjs_options: ["--load-images=no"] })
  end

  Capybara.default_driver = :firefox
  #Capybara.default_driver = :poltergeist

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    reset_email
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

# https://groups.google.com/forum/#!topic/ruby-capybara/VJFbj6_oKgo 
Capybara::Node::Element.class_eval do
  def click_at(x, y)
    right = x - (native.size.width / 2)
    top = y - (native.size.height / 2)
    driver.browser.action.move_to(native).move_by(right.to_i, top.to_i).click.perform
  end
end