class ApplicationController < ActionController::Base
  before_filter :determine_enabled_features
  use_vanity :current_user
  
  protect_from_forgery
  include SessionsHelper
end
