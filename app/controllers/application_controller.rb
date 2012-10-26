class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include ApplicationHelper
  
  before_filter :analyze_visitor
  before_filter :determine_enabled_features
end
