require 'spec_helper'

describe "Pages" do
	it "should have a Home page at '/'" do
		get '/'
		response.should have_selector('title',:content => 'Home')
	end
	
	it "should have a Contact page at '/contact'" do
		get '/contact'
		response.should have_selector('title',:content => 'Contact')
	end
	
	it "should have a About page at '/about'" do
		get '/about'
		response.should have_selector('title',:content => 'About')
	end
	
	it "should have a Help page at '/help'" do
		get '/help'
		response.should have_selector('title',:content => 'Help')
	end
	
	it "should have a Help page at '/signup'" do
		get '/signup'
		response.should have_selector('title',:content => 'Sign up')
	end
	
	describe "when signed out" do
		it "should display a sign in link" do
			visit root_path
			response.should have_selector("a", 
				:href=> signin_path,
				:content=> "Sign in")
		end
		
		it "should have the appropriate links" do
			visit root_path
			click_link "Sign up now!"
			response.should have_selector("title", :content => "Sign up")
			click_link "About"
			response.should have_selector("title", :content => "About")
			click_link "Contact"
			response.should have_selector("title", :content => "Contact")
			click_link "News"
			response.should have_selector("title", :content => "News")
		end
	end
	
	describe "when signed in" do
		before(:each) do
			@user = Factory(:user)
			visit signin_path
			fill_in :email,		:with => @user.email
			fill_in :password,	:with => @user.password
			click_button
		end
		
		it "should have a sign out link" do
			visit root_path
			response.should have_selector("a", 
				:href=> signout_path, 
				:content => "Sign out")
		end
		
		it "should have the appropriate links" do
			visit root_path
			click_link "Home"
			response.should have_selector("title", :content => "Home")
			click_link "Paths"
			response.should have_selector("title", :content => "Paths")
			click_link "Profile"
			response.should have_selector("title", :content => @user.name)
			click_link "Settings"
			response.should have_selector("title", :content => "Settings")
			click_link "Sign out"
			response.should be_success
		end
	end
	
	describe "Sign in/out" do
		describe "failure" do
			it "should not sign a user in" do
				visit signin_path
				fill_in :email,		:with => ""
				fill_in :password, 	:with => ""
				click_button
				response.should have_selector("div.flash.error",
					:content => "Invalid")
			end
		end
		
		describe "success" do
			it "should sign a user in and out" do
				user = Factory(:user)
				visit signin_path
				fill_in :email,		:with => user.email
				fill_in :password, 	:with => user.password
				click_button
				controller.should be_signed_in
				click_link "Sign out"
				controller.should_not be_signed_in
			end
		end
	end
end
