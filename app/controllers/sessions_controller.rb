class SessionsController < ApplicationController
  def new
    if current_user
      redirect_to root_path
    else
      @hide_background = true
      @title = "Sign in"
    end
  end
  
  def request_reset
    if current_user
      redirect_to root_path
    else
      @hide_background = true
    end
  end
  
  def send_reset
    if current_user
      redirect_to root_path
    else
      if user = User.find_by_email(params[:user][:email])
        Mailer.password_reset(user).deliver
        @hide_background = true
      else
        flash[:error] = "Could not find a user account associated with #{params[:user][:email]}."
        redirect_to request_reset_path
      end
    end
  end
  
  def finish_reset
    if current_user
      redirect_to root_path
    else
      if request.get?
        @hide_background = true
        @token = params[:t]
      else
        user = User.find_by_signup_token(params[:session][:t])
        user.password = params[:session][:password]
        user.password_confirmation = params[:session][:password_confirmation]
        if user.save!
          user.reload
          sign_in(user)
          redirect_to root_path
        else
          flash[:error] = user.errors.full_messages.join(". ")
          redirect_to finish_reset_path(params[:t])
        end
      end
    end
  end
  
  def create
    if create_or_sign_in
      if place_to_go_back_to?
        redirect_back
      elsif session[:referer]
        path = Path.find_by_id(session[:referer])
        session[:referer] = nil
        redirect_to challenge_path(path.permalink)
      else
        redirect_to root_path
      end
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