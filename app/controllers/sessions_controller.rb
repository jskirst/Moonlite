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
        sign_in(user)
        redirect_to intro_path and return
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
    current_user.destroy if signed_in?
    redirect_to root_path
  end
  
  def auth_failure
    flash[:error] = params[:message]
    redirect_to new_session_path
  end
end