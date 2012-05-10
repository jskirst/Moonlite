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
	
	def sign_out
		cookies.delete(:remember_token)
		self.current_user = nil
	end
	
	def authenticate
		deny_access unless signed_in?
	end
	
	def company_admin
		unless @enable_administration
			flash[:error] = "You do not have access rights to that resource. Please contact your administrator."
			redirect_to(root_path)
		end
	end
	
	def can_edit_path(path)
		return (@enable_user_creation) && ((path.user == current_user) || (path.company_id = current_user.company_id && @enable_collaboration))
	end
	
	def deny_access
		store_location
		flash[:notice] = "Please sign in to access this page."
		redirect_to signin_path
	end
	
	def redirect_back_or_to(default)
		redirect_to(session[:return_to] || default)
		clear_return_to
	end
	
	def company_logo
		unless current_user.nil?
			return current_user.company.name
		else
			return "Metabright"
		end
	end
	
	def determine_enabled_features
		unless current_user.nil?
			role = current_user.user_role
			@is_consumer = (current_user.company_id == 1)
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
	
	private
		def user_from_remember_token
			User.authenticate_with_salt(*remember_token)
		end
		
		def remember_token
			cookies.signed[:remember_token] || [nil,nil]
		end
		
		def store_location
			session[:return_to] = request.fullpath
		end
		
		def clear_return_to
			session[:return_to] = nil
		end
end
