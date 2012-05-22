class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end
  
  def create
    creds = params[:session]
    user = User.authenticate(creds[:email],creds[:password])
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
