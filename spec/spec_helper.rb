require 'simplecov'
SimpleCov.start

require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However, 
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
  # This file is copied to spec/ when you run 'rails generate rspec:install'# This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures/"
    include ActionDispatch::TestProcess

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    def test_sign_in(user)
      controller.sign_in(user)
    end
    
    def standard_setup(params)
      unless params[:build_user] == false
        @company = FactoryGirl.create(:company)
        
        if params[:user_type] == "admin" || params[:user_type] == "company_admin"
          @admin_user_roll = FactoryGirl.create(:user_roll, :company => @company)
        else
          @regular_user_roll = FactoryGirl.create(:user_roll, :company => @company, :enable_administration => false)
        end
        
        @user = FactoryGirl.create(:user, :company => @company, :user_roll => @user_roll)
        
        if params[:user_type] == "admin"
          @user.toggle!(:admin)
        end
      end
      
      unless params[:build_path] == false
        @category = FactoryGirl.create(:category, :company => @user.company)
        @path = FactoryGirl.create(:path, :user => @user, :company => @user.company, :category => @category)
      end
      
      unless params[:build_section] == false
        @section = FactoryGirl.create(:section, :path => @path)
      end
    end
    
    class Fixnum
      def to_json(options = nil)
        to_s
      end
    end
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
end
