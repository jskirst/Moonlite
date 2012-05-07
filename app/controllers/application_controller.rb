class ApplicationController < ActionController::Base
  before_filter :determine_enabled_features
	
	protect_from_forgery
  include SessionsHelper
end
