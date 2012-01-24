require 'spec_helper'

describe "CompanyUsers" do
	describe "registration" do
		before(:each) do
			@user = Factory(:user)
			@user.company_user.toggle!(:is_admin)
			@user.toggle!(:admin)
		end
		
		describe "invitation" do
			before(:each) do
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
						click_link @user.company.name
						click_link "Add user"
						response.should render_template("company_users/new")
						response.should have_selector("title", :content => "Invite user")
						fill_in "email", :with => @new_user_email
						check "User can add new users"
						click_button "Submit"
						response.should have_selector("div.success")
					end.should change(CompanyUser, :count).by(1)
				end
			end
		end
		
		describe "acceptance" do
			before(:each) do
				@password = "testing"
				@name = "Test User"
			end
			
			it "should add the user to the company and display the company name on their profile" do			
				@new_company_user = Factory(:company_user, :company => @user.company)
				visit accept_user_path(:id => @new_company_user.token1)
				response.should have_selector("title", :content => @user.company.name)
				fill_in :name, :with => @name
				fill_in :password, :with => @password
				fill_in "Confirm password", :with => @password
				click_button
				response.should render_template("users/new")
				response.should have_selector("h1", :content => @name)
				response.should have_selector("a", :content => @user.company.name)
			end
		end
	end
end
