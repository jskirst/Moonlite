class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  include SessionsHelper
  
  before_filter :determine_enabled_features
  before_filter :log_visit
  
  private
  
  def assign_resource(obj, resource_id)
    sr = StoredResource.find(resource_id)
    raise "FATAL: STEALING RESOURCE" if sr.owner_id
    sr.owner_id = obj.id
    sr.owner_type = obj.class.to_s
    sr.save
  end
end
