require 'spec_helper'

describe "Pages" do
	it "should have a Home page at '/'" do
		get '/'
		response.should have_selector('title',:content => 'Home')
	end
	
	it "should have a About page at '/about'" do
		get '/about'
		response.should have_selector('title',:content => 'About')
	end
	
	it "should have a Help page at '/help'" do
		get '/help'
		response.should have_selector('title',:content => 'Help')
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
			click_link "Learn more"
			response.should have_selector("title", :content => "About")
		end
		
		it "should have the appropriate links" do
			visit about_path
			click_link "Request an invite"
			response.should have_selector("title", :content => "Request")
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
			click_link "Explore"
			response.should have_selector("title", :content => "Explore")
			click_link @user.name
			response.should have_selector("title", :content => @user.name)
			click_link "Edit"
			response.should have_selector("title", :content => "Settings")
			click_link "Sign out"
			response.should be_success
		end
	end
	
	describe "Sign in/out" do
		describe "sign in failure" do
			it "should not sign a user in" do
				visit signin_path
				fill_in :email,		:with => ""
				fill_in :password, 	:with => ""
				click_button
				response.should have_selector("div.alert-message.error",
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
