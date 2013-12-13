class ApplicationController < ActionController::Base
  force_ssl unless: :ssl_exempt?
  
  protect_from_forgery
  include ApplicationHelper
  include SessionsHelper
  include NavigationHelper
  include EditorHelper
  
  before_action :determine_enabled_features
  before_action :log_visit
  
  private
  
  def assign_resource(obj, resource_id)
    sr = StoredResource.find(resource_id)
    raise "FATAL: STEALING RESOURCE" if sr.owner_id
      
    sr.owner_id = obj.id
    sr.owner_type = obj.class.to_s
    sr.save
    
    if obj.is_a? Path
      obj.update_attribute(:image_url, sr.obj.url)
    end
    
    return sr
  end

  def ssl_exempt?
    return true if request.subdomain == "employers"
    return true if Rails.env.development?
    return false
  end
end
