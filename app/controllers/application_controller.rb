class ApplicationController < ActionController::Base
  protect_from_forgery
  include ApplicationHelper
  include SessionsHelper
  include NavigationHelper
  include EditorHelper
  
  before_filter :determine_enabled_features
  before_filter :log_visit
  
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
end
