require 'spec_helper'

describe ReportsController do
	render_views
	
	before(:each) do
		@user = Factory(:user)
		@company = Factory(:company)
	end
	
	describe "access controller" do
		describe "when not signed in" do
			it "should deny access to 'dashboard'" do
				get :dashboard
				response.should redirect_to signin_path
			end				
		end
		
		describe "when signed in as a regular user" do
			before(:each) do
				@company_user = Factory(:company_user, :company => @company, :user => @user)
				test_sign_in(@user)
			end
			
			it "should deny access to 'new'" do
				get :dashboard
				response.should redirect_to root_path
			end
		end
		
		describe "when signed in as company admin" do
			before(:each) do
				@company_user = Factory(:company_user, :company => @company, :user => @user, :is_admin => "t")
				test_sign_in(@user)
			end
			
			it "should allow access to 'new'" do
				get :dashboard
				response.should be_success
			end
		end
		
		describe "when signed in as admin" do
			it "should deny access to 'new'" do
				get :dashboard
				response.should redirect_to signin_path
			end
		end
	end

	describe "GET 'dashboard'" do
		before(:each) do
			@company_user = Factory(:company_user, :company => @company, :user => @user, :is_admin => "t")
			test_sign_in(@user)
		end
	
		it "should be successful" do
			get :dashboard
			response.should be_success
		end

		it "should have the right title" do
			get :dashboard
			response.should have_selector("title", :content => "Dashboard")
		end
	end
end