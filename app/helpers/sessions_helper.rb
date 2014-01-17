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
          if User.find_by_email(auth["info"]["email"])
            sign_out
          else
            show_welcome_message = true if user.guest_user?
          end
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
          show_welcome_message = true
          user = User.create_with_omniauth(auth)
        end
      else
        unless current_user
          user = User.create_with_nothing(params[:user])
        end
      end
      user.reload
      sign_in(user)
      if show_welcome_message
        Mailer.welcome(current_user.email).deliver
        UserEvent.log_event(current_user, "Welcome to MetaBright! Check your email for a welcome message from the MetaBright team.")  
      end
      if cookies[:evaluation]
        set_return_back_to(take_group_evaluation_path(cookies[:evaluation]))
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
    
    # nsdub: I think this is necessary only because collaborations isn't up to snuff yet. Should test after collab works well to see if we still need it.
    return true if current_user.enable_administration
    return true if @admin_group and @admin_group.id == path.group_id
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
    flash[:success] = "Please sign in to access this page."
    redirect_to root_path
  end
  
  def place_to_go_back_to?
    !session[:return_back_to].blank?
  end
  def redirect_back
    redirect_to session[:return_back_to]
    clear_return_back_to
  end
  def set_return_back_to(red) session[:return_back_to] = red end
  def clear_return_back_to() session[:return_back_to] = nil end
  
  def name_for_paths() "Challenge" end
  def name_for_personas() "Persona" end
    
  def ongoing_evaluation
    @ongoing_evaluation ||= Evaluation.joins(:evaluation_enrollments)
      .where("evaluation_enrollments.user_id = ?", current_user.id)
      .where("evaluation_enrollments.submitted_at is NULL")
      .select("evaluation_enrollments.*, evaluations.*")
      .first
  end
  
  def determine_enabled_features
    return unless current_user
    @enable_administration = current_user.enable_administration
    return if request.xhr?
    
    @groups = Group.joins("INNER JOIN group_users on group_users.group_id=groups.id")
      .where("groups.closed_at is ?", nil)
      .where("group_users.user_id = ?", current_user.id)
      .select("group_users.is_admin, groups.*")
      .to_a
      
    @admin_groups = @groups.select{ |g| g.is_admin? }
    @admin_groups = nil if @admin_groups.empty?
    if @admin_groups
      group_id = params[:g] || session[:g]
      if group_id
        @admin_group = @admin_groups.select{ |g| g.id.to_s == group_id.to_s }.first
      end
      if @admin_group.nil?
        @admin_group = @admin_groups.first
      end
      session[:g] = @admin_group.id
    end
  end
  
  def social_image
    @social_image || "https://s3.amazonaws.com/moonlite-nsdub/static/GiantStoney.png"
  end
  
  def social_title
    @social_title || "Credit Report for Your Skills | MetaBright"
  end
  
  def social_description
    @social_description || "MetaBright is a skills assessment platform that makes it easier to hire and be hired."
  end
  
  def store_location(location = nil)
    session[:return_to] = location || request.fullpath
  end

  def current_path_difficulty(path, new_difficulty = nil)
    if new_difficulty
      difficulty = new_difficulty
    else
      difficulty = session["difficulty.#{path.id}"].to_f
      difficulty = 0.85 if difficulty < 0.85
    end
    session["difficulty.#{path.id}"] = difficulty
    return difficulty
  end
  
  private
    def log_visit
      begin
        unless params[:action] == "raw" or request.env["HTTP_USER_AGENT"].match(/\(.*https?:\/\/.*\)/)
          if not request.xhr? or params[:action] == "hovercard"
            if current_user
              visitor_id = cookies[:visitor_id].to_i > 0 ? cookies[:visitor_id].to_i : nil
              #@visit = Visit.create!(user_id: current_user.id, visitor_id: visitor_id, request_url: request.url, referral_url: request.env["HTTP_REFERER"], user_agent: request.env["HTTP_USER_AGENT"], remote_ip: request.remote_ip )
            else
              if cookies[:visitor_id].to_i > 0
                visitor_id = cookies[:visitor_id]  
              else
                visitor_id = rand(1000000000)
                cookies.permanent[:visitor_id] = visitor_id
              end
              #@visit = Visit.create!(visitor_id: visitor_id, request_url: request.url, referral_url: request.env["HTTP_REFERER"])
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
end
