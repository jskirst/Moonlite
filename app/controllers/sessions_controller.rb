class SessionsController < ApplicationController
  def new
    if current_user
      redirect_to root_path
    else
      @title = "Sign in"
    end
  end
  
  def create
    create_or_sign_in
    if session[:referer]
      path = Path.find_by_id(session[:referer])
      session[:referer] = nil
      redirect_to challenge_path(path.permalink)
    else
      redirect_to root_path
    end
  end
  
  def destroy
    sign_out
    redirect_to root_path
  end
  
  def visit
    @visit = Visit.find_by_external_id(params[:external_id])
    @visit.update_attribute(:updated_at, Time.now())
    render json: { status: "success" }
  end
  
  def share
    redirect_to params[:url]
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