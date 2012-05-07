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
			return "Moonlite"
		end
	end
	
	def determine_enabled_features
		unless current_user.nil?
			roll = current_user.user_roll
			@is_consumer = (current_user.company_id == 1)
			@enable_administration = roll.enable_administration
			@enable_rewards = roll.enable_company_store
			@enable_leaderboard = roll.enable_leaderboard
			@enable_dashboard = roll.enable_dashboard
			@enable_tour = roll.enable_tour
			@enable_browsing = roll.enable_browsing
			@enable_comments = roll.enable_comments
			@enable_news = roll.enable_news
			@enable_feedback = roll.enable_feedback
			@enable_achievements = roll.enable_achievements
			@enable_recommendations = roll.enable_recommendations
			@enable_printer_friendly = roll.enable_printer_friendly
			@enable_user_creation = roll.enable_user_creation
			@enable_auto_enroll = roll.enable_auto_enroll
			@enable_one_signup = roll.enable_one_signup
			@enable_collaboration = roll.enable_collaboration
			@enable_auto_generate = roll.enable_auto_generate
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
