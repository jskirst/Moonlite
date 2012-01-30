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
			flash[:success] = "Hello Project Moonlite demo visitors!
			A little info about the demo - all the content on this account is randomly generated to give an idea of what a living Moonlite account might look like. Because new features are moving and changing so fast we haven't really invested just yet in static content for Paths other than on our local machines.
			Also, please feel free to take the tour (link at the top right), though you may notice that it is often slightly out of date, as we only update it after new features are live. Hope you enjoy!"
			sign_in user
			redirect_back_or_to user
		end
	end
	
	def destroy
		sign_out
		redirect_to root_path
	end
end
