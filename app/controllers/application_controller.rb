class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  
  before_filter :analyze_visitor
  before_filter :determine_enabled_features
  use_vanity :current_user
end
