require 'spec_helper'

describe CompanyUsersController do
	render_views
	
	before(:each) do
		@user = Factory(:user)
		@company = Factory(:company)
		@attr = { :company_id => @company.id, :email => "testXYZ@testing.com", :is_admin => true }
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
			response.should have_selector("title", :content => "Invite user")
		end
		
		it "should render the new page" do
			get :new, :company => @company
			response.should render_template("company_users/new")
		end
	end
	
	describe "POST 'create'" do
		before(:each) do
			test_sign_in(@user)
		end
		
		describe "failure" do
			describe "because of bad email argument" do
				it "should not create an company_user" do
					lambda do
						post :create, :company_user => {:company_id => @company.id, :email => ""}  
					end.should_not change(CompanyUser, :count)
				end
				
				it "should take you back to the root path" do
					post :create, :company_user => {:company_id => @company.id, :email => ""} 
					response.should redirect_to root_path
				end
			end
			
			describe "because of bad company argument" do
				it "should not create an company_user" do
					lambda do
						post :create, :company_user => {:company_id => "abc", :email => "testXYZ2@testing"}  
					end.should_not change(CompanyUser, :count)
				end
				
				it "should take you back to the root path" do
					post :create, :company_user => {:company_id => "abc", :email => "testXYZ2@testing"}  
					response.should redirect_to root_path
				end
			end
		end
		
		describe "success" do
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
	