class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include ApplicationHelper
  
  before_filter :determine_enabled_features
  
  private
  
  def log_event(user, link, image_link, content)
    return false if user == current_user
    if user.nil?
      e = current_user.user_events.new(actioner_id: nil)
    else
      e = user.user_events.new(action_id: current_user.id)
    end
    e.link = link
    e.image_link = image_link
    e.content = content
    e.save!
  end
  
  def unlock_contribution
    log_event(nil, root_url, nil, "Congratulations! You have unlocked the ability to contribute new questions and tasks to Challenges.")
  end
end
