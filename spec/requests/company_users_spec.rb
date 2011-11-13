require 'spec_helper'

describe "CompanyUsers" do
	describe "invitation" do
		before(:each) do
			@user = Factory(:user)
			@user.toggle!(:admin)
			@company = Factory(:company)
			@new_user_email = "jskirst@gmail.com"
			
			visit signin_path
			fill_in :email, :with => @user.email
			fill_in :password, :with => @user.password
			click_button
			visit companies_path
		end
	
		describe "success" do
			it "should invite a new company user" do
				lambda do
					click_link @company.name
					click_link "Add user"
					response.should render_template("company_users/new")
					response.should have_selector("title", :content => @company.name)
					fill_in "email", :with => @new_user_email
					click_button "Submit"
					response.should have_selector("div.success")
				end.should change(CompanyUser, :count).by(1)
			end
		end
	end
	
	describe "acceptance" do
		before(:each) do
			@company = Factory(:company)
			@company_user = Factory(:company_user, :company => @company)
			@password = "testing"
			@name = "Test User"
		end
		
		it "should add the user to the company and display the company name on their profile" do			
			visit accept_user_path(:id => @company_user.token1)
			response.should have_selector("title", :content => @company.name)
			fill_in :name, :with => @name
			fill_in :password, :with => @password
			fill_in "Confirm password", :with => @password
			click_button
			response.should render_template("users/new")
			response.should have_selector("h1", :content => @name)
			response.should have_selector("a", :content => @company.name)
		end
	end
end
