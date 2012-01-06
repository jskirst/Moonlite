require 'spec_helper'

describe "CompanyUsers" do
	describe "registration" do
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
						check "Is admin"
						click_button "Submit"
						response.should have_selector("div.success")
					end.should change(CompanyUser, :count).by(1)
				end
			end
		end
		
		describe "acceptance" do
			before(:each) do
				@company = Factory(:company)
				@company_user = Factory(:company_user, :company => @company, :is_admin => "true")
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
	
	describe "access level" do
		before(:each) do
			@admin_user = Factory(:user)
			@company = Factory(:company)
			@admin_company_user = Factory(:company_user, 
				:company => @company, 
				:email => @admin_user.email, 
				:user => @admin_user, 
				:is_admin => "t")
			
			@non_admin_user = Factory(:user, :email => "other_user@t.com")
			@non_admin_company_user = Factory(:company_user,
				:company => @company,
				:email => @non_admin_user.email,
				:user_id => @non_admin_user.id,
				:is_admin => "f")
		end
	
		describe "as admin user" do
			it "should allow user on company page" do
				visit signin_path
				fill_in :email, :with => @admin_user.email
				fill_in :password, :with => @admin_user.password
				click_button
				click_link "My Company"
				response.should have_selector("h1", :content => @company.name)
				response.should have_selector("li", :content => @admin_user.name)
				response.should have_selector("li", :content => @non_admin_user.name)
			end
		end
		
		describe "as a non-admin user" do
			it "should not allow user on company page" do
				visit signin_path
				fill_in :email, :with => @non_admin_user.email
				fill_in :password, :with => @non_admin_user.password
				click_button
				response.should_not have_selector("a", :content => "My Company")
				visit company_path @company
				response.should have_selector("title", :content => "Home")
			end
		end
	end
end
