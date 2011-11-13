require 'spec_helper'

describe CompanyUsersController do
	render_views
	
	before(:each) do
		@user = Factory(:user)
		@new_user = Factory(:user, :email => "new_user@test.com")
		@company = Factory(:company)
		@company_user = Factory(:company_user, :company => @company, :email => @new_user.email)
		@token1 = @company_user.token1
		@token2= @company_user.token2
	end
	
	describe "access controller" do
		it "should deny access to 'new'" do
			get :new
			response.should redirect_to(signin_path)
		end
		
		it "should deny access to 'create'" do
			post :create
			response.should redirect_to(signin_path)
		end
	end
	
	describe "GET 'new'" do
		before(:each) do
			test_sign_in(@user)
		end
		
		it "should be successful" do
			get :new, :company => @company
			response.should be_success
		end

		it "should have right title" do
			get :new, :company => @company
			response.should have_selector("title", :content => @company.name)
		end
	end
	
	describe "POST 'create'" do
		before(:each) do
			test_sign_in(@user)
		end
		
		describe "failure" do
			before(:each) do
				@attr = { :company_id => "", :email => ""}
			end
		
			it "should not create an company_user" do
				lambda do
					post :create, :company_user => @attr  
				end.should_not change(CompanyUser, :count)
			end
			
			it "should take you back to the root path" do
				post :create, :company_user => @attr
				response.should redirect_to root_path
			end
		end
		
		describe "success" do
			before(:each) do
				@attr = { :company_id => @company.id, :email => "testXYZ@testing.com" }
			end
			
			it "should create an company_user" do
				lambda do
					post :create, :company_user => @attr
				end.should change(CompanyUser, :count).by(1)		
			end
			
			it "should go back to the company page" do
				post :create, :company_user => @attr
				response.should redirect_to(@company)
			end
			
			it "should have a flash message" do
				post :create, :company_user => @attr
				flash[:success].should =~ /invited/i
			end
		end
	end
end
	