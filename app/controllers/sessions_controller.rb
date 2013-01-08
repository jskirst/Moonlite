class SessionsController < ApplicationController
  def new
    if signed_in?
      redirect_to root_path
    else
      @title = "Sign in"
    end
  end
  
  def create
    auth = request.env["omniauth.auth"]
    if auth
      if user = User.find_with_omniauth(auth)
        sign_in(user)
      elsif user = User.find_by_email(auth["info"]["email"])
        if user.merge_with_omniauth(auth)
          sign_in(user)
        else
          flash[:error] = "An error occured. Please try another form of authentication."
        end
      else
        user = User.create_with_omniauth(auth)
        user.set_viewed_help(session[:viewed_help])
        user.reload
        sign_in(user)
        Mailer.welcome(current_user.email).deliver
        log_event(nil, root_url, nil, "Welcome to MetaBright! Check your email for a welcome message from the MetaBright team.")
        if session[:referer]
          session[:referrer] = nil
          path = Path.find_by_id(session[:referer])
          current_user.enroll!(path)
          redirect_to continue_path_path(path)
        else
          redirect_to intro_path
        end
        return true
      end
    else
      credentials = params[:session]
      if user = User.authenticate(credentials[:email],credentials[:password])
        sign_in(user)
      else
        flash.now[:error] = "Invalid email/password combination."
        render('new') and return
      end
    end
    redirect_back_or_to root_path
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end
  
  # Secret methods to help with testing
  def locallink
    redirect_to "http://localhost:3000/auth/facebook/callback?code=#{params[:code]}"
  end
  
  def auth_failure
    flash[:error] = params[:message]
    redirect_to new_session_path
  end
end