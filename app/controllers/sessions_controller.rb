class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end
  
  def create
    auth = request.env["omiauth.auth"]
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
  
  def destroy
    sign_out
    if @is_consumer
      redirect_to root_path(:m => "c")
    else
      redirect_to root_path
    end
  end
end
