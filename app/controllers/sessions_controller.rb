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
        @email = params[:user][:email]
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
  
  def share
    redirect_to params[:url]
  end
  
  # Secret methods to help with testing
  def locallink
    redirect_to "http://localhost:3000/auth/facebook/callback?code=#{params[:code]}"
  end
  
  def auth_failure
    if current_user
      flash[:error] = "There was an error trying to sign up using your social login."
      redirect_to profile_path(current_user.username)
    else
      if cookies[:evaluation]
        flash[:error] = "There was an error trying to sign up using your social login. Please create an account using your email and a password."
        redirect_to take_group_evaluation_path(cookies[:evaluation], error: "sociallogin")
        cookies.delete :evaluation
      else
        flash[:error] = "There was an error trying to sign up using your social login. Please create an account using your email and a password."
        redirect_to new_user_path
      end
    end
  end
end