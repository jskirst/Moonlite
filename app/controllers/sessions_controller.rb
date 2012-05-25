class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end
  
  def create
    auth = request.env["omniauth.auth"]
    if auth
      user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.create_with_omniauth(auth)
    else
      credentials = params[:session]
      user = User.authenticate(credentials[:email],credentials[:password])
    end
    
    if user.nil?
      @title = "Sign in"
      flash.now[:error] = "Invalid email/password combination."
      render 'new'
    else
      sign_in user
      redirect_back_or_to root_path
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
    else
      redirect_to root_path
    end
  end
end
