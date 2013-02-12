module SessionsHelper
  def sign_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    self.current_user= user
  end
  
  def signed_in?
    !current_user.nil?
  end
  
  def current_user=(user)
    @current_user = user
  end
  
  def current_user
    @current_user ||= user_from_remember_token
  end
  
  def current_user?(user)
    user == current_user
  end
  
  def current_company
    current_user.company if current_user
    Company.find(1)
  end
  
  def show_sign_in
    return @show_sign_in.nil? ? true : @show_sign_in
  end
  
  def show_footer
    return @show_footer.nil? ? true : @show_footer
  end
  
  def show_nav_bar
    return @show_nav_bar.nil? ? true : @show_nav_bar
  end
  
  def get_viewed_help
    if current_user
      return current_user.get_viewed_help
    else
      session[:viewed_help].nil? ? [] : session[:viewed_help]
    end
  end
  
  def unread_notification_count
    return 0 unless current_user
    current_user.user_events.unread.count
  end
  
  def notifications
    return [] unless current_user
    current_user.user_events.order("created_at DESC")
  end
  
  def sign_out
    cookies.delete(:remember_token)
    self.current_user = nil
  end
  
  def authenticate
    if not signed_in?
      deny_access 
    elsif current_user.locked?
      sign_out
      redirect_to root_url
    end
  end
  
  def admin_only
    flash[:error] = "You do not have access to that functionality."
    redirect_to(root_path) unless current_user.admin?
  end
  
  def can_edit_path(path)
    return true if path.user == current_user
    return true if path.collaborations.find_by_user_id(current_user.id)
    return false
  end
  
  def can_add_tasks(path)
    e = current_user.enrollments.find_by_path_id(path.id)
    e = current_user.enroll!(path) if e.nil?
    if path.user == current_user && e.contribution_unlocked_at.nil?
      e.update_attribute(:contribution_unlocked_at, Time.now)
    end
    return e.contribution_unlocked?
  end
  
  def deny_access
    store_location
    logger.debug "Access Denied: requires logged in user"
    flash[:notice] = "Please sign in to access this page."
    redirect_to root_path
  end
  
  def redirect_back_or_to(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end
  
  def name_for_paths() "Challenge" end
  def name_for_personas() "Persona" end
  
  def determine_enabled_features
    unless current_user.nil?
      role = current_user.user_role
      @is_consumer = true
      @enable_administration = role.enable_administration
    end
  end
  
  def social_image
    @social_image || "https://s3-us-west-1.amazonaws.com/moonlite/static/logo.png"
  end
  
  def social_title
    @social_title || "MetaBright - Prove and Promote your Skills"
  end
  
  def social_description
    @social_description || "If you're not a nerd about something, do you really exist?"
  end
  
  def store_location(location = nil)
    session[:return_to] = location || request.fullpath
  end
  
  private
    def log_visit
      unless request.xhr?
        if current_user
          visitor_id = cookies[:visitor_id].to_i > 0 ? cookies[:visitor_id].to_i : nil
          Visit.create!(user_id: current_user.id, visitor_id: visitor_id, request_url: request.url)
          #current_user.update_attribute(:login_at, DateTime.now())
        else
          if cookies[:visitor_id].to_i > 0
            visitor_id = cookies[:visitor_id]  
          else
            visitor_id = rand(1000000000)
            cookies.permanent[:visitor_id] = visitor_id
          end
          Visit.create!(visitor_id: visitor_id, request_url: request.url)
        end
      end
    end
  
    def user_from_remember_token
      User.authenticate_with_salt(*remember_token)
    end
    
    def remember_token
      cookies.signed[:remember_token] || [nil,nil]
    end
    
    def clear_return_to
      session[:return_to] = nil
    end
end
