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
  
  def notifications
    return [] unless current_user
    current_user.user_events.where("is_read = ?", false)
  end
  
  def sign_out
    cookies.delete(:remember_token)
    self.current_user = nil
  end
  
  def authenticate
    if not signed_in?
      deny_access 
    elsif current_user.is_locked?
      sign_out
      redirect_to root_url
    end
  end
  
  def admin_only
    flash[:error] = "You do not have access to that functionality."
    redirect_to(root_path) unless current_user.admin?
  end
  
  def company_admin
    unless @enable_administration
      flash[:error] = "You do not have access rights to that resource. Please contact your administrator."
      redirect_to(root_path)
    end
  end
  
  def can_edit_path(path)
    return false unless @enable_user_creation #creation enabled for your user role and...
    return true if path.user == current_user #1) You are the path creator or...
    return true if path.company_id = current_user.company_id && @enable_collaboration #2) Your org enables org wide collaboration
    return true if path.collaborations.find_by_user_id(current_user.id) #3) Your listed as a collaborator
    return false
  end
  
  def deny_access
    store_location
    flash[:notice] = "Please sign in to access this page."
    redirect_to root_path
  end
  
  def redirect_back_or_to(default)
    redirect_to(session[:return_to] || default)
    clear_return_to
  end
  
  def company_logo
    unless current_user.nil?
      return current_user.company.name
    else
      @possible_company ? @possible_company.name : "MetaBright"
    end
  end
  
  def name_for_paths
    unless current_user.nil? || current_user.company.name_for_paths.nil?
      return current_user.company.name_for_paths.capitalize
    else
      return "Challenge"
    end
  end
  
  def name_for_personas
    return "Path"
  end
  
  def analyze_visitor
    if current_user
      if current_user.company_id == 1
        @is_consumer = true
      else
        @is_company = true
        cookies.permanent[:mb_c] = current_company.id
      end
    elsif params[:c]
      @possible_company = Company.where("referrer_url like ?", "%#{params[:c]}%").first
      @is_company = true if @possible_company
      @is_consumer = false
      cookies.permanent[:mb_c] = @possible_company.id
    elsif cookies[:mb_c]
      @possible_company = Company.find(cookies[:mb_c].to_i)
      @is_company = true if @possible_company
      @is_consumer = false
    else
      http_host = request.env["HTTP_HOST"]
      domain = http_host.split(".")[-2].to_s.downcase
      @possible_company = Company.where("referrer_url ILIKE ?", "%#{domain}%").first
      @is_company = true if @possible_company
    end
  end
  
  def determine_enabled_features
    unless current_user.nil?
      role = current_user.user_role
      @enable_administration = role.enable_administration
      @enable_rewards = role.enable_company_store
      @enable_leaderboard = role.enable_leaderboard
      @enable_dashboard = role.enable_dashboard
      @enable_tour = role.enable_tour
      @enable_browsing = role.enable_browsing
      @enable_comments = role.enable_comments
      @enable_news = role.enable_news
      @enable_feedback = role.enable_feedback
      @enable_achievements = role.enable_achievements
      @enable_recommendations = role.enable_recommendations
      @enable_printer_friendly = role.enable_printer_friendly
      @enable_user_creation = role.enable_user_creation
      @enable_auto_enroll = role.enable_auto_enroll
      @enable_one_signup = role.enable_one_signup
      @enable_collaboration = role.enable_collaboration
      @enable_auto_generate = role.enable_auto_generate
    end
  end
  
  def social_image
    @social_image || "https://s3-us-west-1.amazonaws.com/moonlite/static/logo.png"
  end
  
  def social_title
    @social_title || "MetaBright - Bowties are cool"
  end
  
  def social_description
    @social_description || "If you're not a nerd about something, do you really exist?"
  end
  
  def store_location(location = nil)
    session[:return_to] = location || request.fullpath
  end
  
  private
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
