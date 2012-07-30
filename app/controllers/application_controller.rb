class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  
  before_filter :analyze_visitor
  before_filter :determine_enabled_features
  before_filter :test_test_test
  use_vanity :current_user
  
  def test_test_test
    raise request.env.to_yaml
  end
end
