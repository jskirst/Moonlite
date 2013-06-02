module SessionsHelper
  def authenticate
    if not current_user
      deny_access 
    elsif current_user.locked?
      sign_out
      redirect_to root_url
    end
  end
  
  def create_or_sign_in
    if params[:session]
      credentials = params[:session]
      if user = User.authenticate(credentials[:email],credentials[:password])
        sign_in(user)
      else
        flash[:error] = "Invalid email/password combination."
        redirect_to signin_path
        return false
      end
    else
      auth = request.env["omniauth.auth"]
      if auth
        if user = current_user
          user.merge_existing_with_omniauth(auth)
        elsif user = User.find_with_omniauth(auth)
          sign_in(user)
        elsif user = User.find_by_email(auth["info"]["email"])
          if user.merge_with_omniauth(auth)
            sign_in(user)
          else
            flash[:error] = "An error occured. Please try another form of authentication."
          end
        else
          user = User.create_with_omniauth(auth)
        end
      else
        unless current_user
          user = User.create_with_nothing(params[:user])
        end
      end
      user.reload
      sign_in(user)
      user.set_viewed_help(session[:viewed_help])
      if (not user.guest_user?) and user.created_at > 30.minutes.ago
        Mailer.welcome(current_user.email).deliver
        UserEvent.log_event(current_user, "Welcome to MetaBright! Check your email for a welcome message from the MetaBright team.")  
      end
      return true
    end
  end
  
  def sign_in(user)
    cookies.permanent.signed[:remember_token] = [user.id, user.salt]
    self.current_user= user
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
  
  def hide_background
    return @hide_background.nil? ? false : @hide_background
  end
  
  def show_header
    return @show_header.nil? ? true : @show_header
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
    notifications.select{ |n| n.read_at.nil? }.size
  end
  
  def notifications
    return [] unless current_user
    UserEvent.cached_find_by_user_id(current_user.id)
  end
  
  def sign_out
    cookies.delete(:remember_token)
    self.current_user = nil
  end
  
  def admin_only
    flash[:error] = "You do not have access to that functionality."
    redirect_to(root_path) unless current_user.admin?
  end
  
  def can_edit_path(path)
    return true if path.user_id == current_user.id
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
    unless ["raw"].include?(params[:action])
      if current_user
        @is_consumer = true
        @enable_administration = current_user.enable_administration == "t"
      end
    end
  end
  
  def social_image
    @social_image || "https://s3.amazonaws.com/moonlite-nsdub/static/Stoney+128x128.png"
  end
  
  def social_title
    @social_title || "MetaBright - Prove and Promote your Skills"
  end
  
  def social_description
    @social_description || "MetaBright is the game that can land you your next job or internship!"
  end
  
  def store_location(location = nil)
    session[:return_to] = location || request.fullpath
  end
  
  private
    def log_visit
      begin
        unless params[:action] == "raw"
          if not request.xhr? or params[:action] == "hovercard"
            if current_user
              visitor_id = cookies[:visitor_id].to_i > 0 ? cookies[:visitor_id].to_i : nil
              @visit = Visit.create!(user_id: current_user.id, visitor_id: visitor_id, request_url: request.url, referral_url: request.env["HTTP_REFERER"])
            else
              if cookies[:visitor_id].to_i > 0
                visitor_id = cookies[:visitor_id]  
              else
                visitor_id = rand(1000000000)
                cookies.permanent[:visitor_id] = visitor_id
              end
              @visit = Visit.create!(visitor_id: visitor_id, request_url: request.url, referral_url: request.env["HTTP_REFERER"])
            end
          end
        end
      rescue
        logger.debug "Error: #{$!}"
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
