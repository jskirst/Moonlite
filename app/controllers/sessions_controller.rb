class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end
  
  def create
    auth = request.env["omniauth.auth"]
    if auth
      if current_user
        if current_user.merge_with_omniauth(auth)
          track_session(:register, current_user, auth)
        else
          flash[:error] = "An error occured. Please try another form of authentication."
        end
      else
        if user = User.find_with_omniauth(auth)
          sign_in(user) and track_session(:login, user, auth)
        elsif user = User.find_by_email(auth["info"]["email"])
          if user.merge_with_omniauth(auth)
            sign_in(user) and track_session(:login, user, auth)
          else
            flash[:error] = "An error occured. Please try another form of authentication."
          end
        else
          flash.now[:info] = "You must already have a Metabright account to login with #{auth["provider"].capitalize}."
          render('new') and return
        end
      end
    else
      credentials = params[:session]
      if user = User.authenticate(credentials[:email],credentials[:password])
        sign_in(user) and track_session(:login_conventional, user)
      else
        flash.now[:error] = "Invalid email/password combination."
        render('new') and return
      end
    end
    redirect_back_or_to root_path
  end
  
  def destroy
    track_session(:logout, current_user)
    sign_out
    if @is_consumer
      redirect_to root_path(:m => "c")
    else
      redirect_to root_path
    end
  end
  
  # Secret methods to help with testing
  def locallink
    redirect_to "http://localhost:3000/auth/facebook/callback?code=#{params[:code]}"
  end
  
  def out_and_delete
    current_user.destroy
    redirect_to root_path
  end
  
  def auth_failure
    flash[:error] = params[:message]
    redirect_to new_session_path
  end
  
  private
  def track_session(action, user, auth = {})
    unless user.admin? || user.is_test_user
      if action == :register
        track! :registration_facebook if auth["provider"] == "facebook"
        track! :registration_google if auth["provider"] == "google_oauth2"
      elsif action == :login
        track! :login_facebook if auth["provider"] == "facebook"
        track! :login_google if auth["provider"] == "google_oauth2"
      elsif action == :login_conventional
        track! :login_conventional
      elsif action == :logout
        track! :logout
      else
        raise [action.to_s, user.to_s, auth.to_s].join("::").to_s
      end
    end
  end

end