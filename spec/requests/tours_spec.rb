require 'spec_helper'

describe "Tours" do
	before(:each) do
		@user = Factory(:user)
		
		@final_user_tour_page = 4
		@final_admin_tour_page = 8
	end

	describe "as a regular user" do
		before(:each) do
			visit signin_path
			fill_in :email, :with => @user.email
			fill_in :password, :with => @user.password
			click_button
		end
		
		it "should go to the user tour" do
			visit root_path
			click_link "Take the tour"
			response.should have_selector("title", :content => "Moonlite Tour")
		end
		
		it "should have 4 steps" do
			visit root_path
			click_link "Take the tour"
			response.should have_selector("h2", :content => "Home")
			click_link "Next"
			response.should have_selector("h2", :content => "Paths")
			click_link "Next"
			response.should have_selector("h2", :content => "Company Store")
			click_link "Next"
			response.should have_selector("h2", :content => "Bon Voyage!")
			click_link "Finish"
			response.should have_selector("title", :content => "Home")
		end
		
		describe "finale" do
			it "should have a link to enroll in a new Path" do
				visit user_tour_tour_path(@final_user_tour_page)
				click_link "View Paths"
				response.should have_selector("title", :content => "All Paths")
			end
			
			it "should have a link to home page" do
				visit user_tour_tour_path(@final_user_tour_page)
				click_link "Go Home"
				response.should have_selector("title", :content => "Home")
			end
			
			it "should have a link to user profile" do
				visit user_tour_tour_path(@final_user_tour_page)
				click_link "My Profile"
				response.should have_selector("title", :content => @user.name)
			end
		end
	end
	
	describe "as an admin user" do
		before(:each) do
			@user.company_user.toggle!(:is_admin)
			visit signin_path
			fill_in :email, :with => @user.email
			fill_in :password, :with => @user.password
			click_button
		end
		
		it "should start at the choose page" do
			visit tours_path
			response.should have_selector("h1", :content => "A stroll in the Moonlite")
			click_link "admin_tour_link"
			response.should have_selector("h1", :content => "Moonlite Administrator Tour")
		end
		
		it "should have 8 steps" do
			visit admin_tour_tour_path(1)
			response.should have_selector("h2", :content => "Home")
			click_link "Next"
			response.should have_selector("h2", :content => "Paths")
			click_link "Next"
			response.should have_selector("h2", :content => "Creating Paths")
			click_link "Next"
			response.should have_selector("h2", :content => "Path Marketplace")
			click_link "Next"
			response.should have_selector("h2", :content => "Company Store")
			click_link "Next"
			response.should have_selector("h2", :content => "My Company")
			click_link "Next"
			response.should have_selector("h2", :content => "Dashboard")
			click_link "Next"
			response.should have_selector("h2", :content => "Bon Voyage")
			click_link "Finish"
			response.should have_selector("title", :content => "Home")
		end
		
		describe "finale" do
			it "should have a link to the Path Marketplace" do
				visit admin_tour_tour_path(@final_admin_tour_page)
				click_link "Marketplace"
				response.should have_selector("title", :content => "Marketplace")
			end
			
			it "should have a link to create a new path" do
				visit admin_tour_tour_path(@final_admin_tour_page)
				click_link "New Path"
				response.should have_selector("title", :content => "New Path")
			end
			
			it "should have a link to invite a new user" do
				visit admin_tour_tour_path(@final_admin_tour_page)
				click_link "Add Users"
				response.should have_selector("title", :content => "Invite user")
			end
		end
	end
end
