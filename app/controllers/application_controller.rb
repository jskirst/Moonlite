class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  include SessionsHelper
  
  before_filter :determine_enabled_features
  before_filter :log_visit
end
