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
	
	# def verify_ownership
		# if @owner_id != current_user.company.id
			# flash[:error] = "You do not have access to this data."
			# redirect_to root_path
		# end
	# end
	
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
