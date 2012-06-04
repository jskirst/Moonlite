class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end
  
  def create
    auth = request.env["omniauth.auth"]
    back_or_root = request.env['HTTP_REFERER'] || root_path
    
    if current_user
      if auth
        current_user.merge_with_omniauth(auth)
        track! :registration_facebook
        redirect_to back_or_root+"?reg=true&"
      else
        flash[:info] = "You are already signed in."
        redirect_to back_or_root
      end
    elsif auth    
      user = User.find_by_provider_and_uid_and_company_id(auth["provider"], auth["uid"], 1)
      if user
        sign_in user
        track! :login_facebook
        redirect_to root_path
      else
        if request.env['HTTP_REFERER'] && request.env['HTTP_REFERER'].include?("signin")
          flash.now[:info] = "You must already have an account to login with Facebook."
          render 'new'
        else
          user = User.create_with_omniauth(auth)
          track! :registration_facebook
          redirect_to back_or_root
        end
      end
    else
      credentials = params[:session]
      user = User.authenticate(credentials[:email],credentials[:password])
      if user
        sign_in user
        redirect_back_or_to root_path
        unless user.is_test_user || user.admin?
          track! :login_conventional
        end
      else
        @title = "Sign in"
        flash.now[:error] = "Invalid email/password combination."
        render 'new'
      end
    end
  end
  
  def auth_failure
    flash[:error] = params[:message]
    redirect_to new_session_path
  end
  
  def locallink
    redirect_to "http://localhost:3000/auth/facebook/callback?code=#{params[:code]}"
  end
  
  def destroy
    sign_out
    if @is_consumer
      redirect_to root_path(:m => "c")
      track! :logout
    else
      redirect_to root_path
    end
  end
end
