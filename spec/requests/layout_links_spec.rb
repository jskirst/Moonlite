require 'spec_helper'

describe "LayoutLinks" do
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
	
	it "Should have the right links on the layout" do
		visit root_path
		click_link "About"
		response.should have_selector("title", :content => "About")
		click_link "Help"
		response.should have_selector("title", :content => "Help")
		click_link "Contact"
		response.should have_selector("title", :content => "Contact")
		click_link "Home"
		response.should have_selector("title", :content => "Home")
		click_link "Sign up now!"
		response.should have_selector("title", :content => "Sign up")
	end
	
	describe "when signed out" do
		it "should display a sign in link" do
			visit root_path
			response.should have_selector("a", 
				:href=> signin_path,
				:content=> "Sign in")
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
		
		it "should display a profile link" do
			visit root_path
			response.should have_selector("a",
				:content => "Profile",
				:href => user_path(@user))
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
