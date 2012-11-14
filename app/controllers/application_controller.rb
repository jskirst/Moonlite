class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include ApplicationHelper
  
  before_filter :analyze_visitor
  before_filter :determine_enabled_features
  
  private
  
  def log_event(user, link, image_link, content)
    user.user_events.create!(
      actioner_id: current_user.id,
      link: link,
      image_link: image_link,
      content: content
    )
  end
end
