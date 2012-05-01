require 'spec_helper'

describe EnrollmentsController do
	render_views
	
	describe "access controller" do	
		it "should deny access to 'create'" do
			post :create
			response.should redirect_to(signin_path)
		end
		
		it "should deny access to 'delete'" do
			delete :destroy, :id => 1
			response.should redirect_to(signin_path)
		end
	end
	
	describe "POST 'create'" do
		before(:each) do
			@user = Factory(:user)
			@path = Factory(:path, :user => @user, :company => @user.company)
			test_sign_in(@user)
		end
		
		describe "failure" do
			before(:each) do
				@attr = { :user_id => "", :path_id => ""}
			end
		
			it "should not create an enrollment" do
				lambda do
					post :create, :enrollment => @attr  
				end.should_not change(Enrollment, :count)
			end
			
			it "should take you back to the root path" do
				post :create, :enrollment => @attr
				response.should redirect_to root_path
			end
		end
		
		describe "success" do
			before(:each) do
				@attr = { :user_id => @user.id, :path_id => @path.id }
			end
			
			it "should create an enrollment" do
				lambda do
					post :create, :enrollment => @attr
				end.should change(Enrollment, :count).by(1)		
			end
			
			it "should go back to the path page" do
				post :create, :enrollment => @attr
				response.should redirect_to(@path)
			end
			
			it "should have a flash message" do
				post :create, :enrollment => @attr
				flash[:success].should =~ /enrolled/i
			end
		end
	end
	
	describe "DELETE 'destroy'" do
		describe "as an unauthorized user" do
			before(:each) do
				@user = Factory(:user)
				@path = Factory(:path, :user => @user, :company => @user.company)
				@enrollment = Factory(:enrollment, :path => @path, :user => @user)
				
				@other_user = Factory(:user, :email => "o@o.com")
				test_sign_in(@other_user)
			end
			
			it "should deny access" do
				delete :destroy, :id => @enrollment
				response.should redirect_to(root_path)
			end
		end
		
		describe "as an authorized user" do
			before(:each) do
				@user = test_sign_in(Factory(:user))
				@path = Factory(:path, :user => @user, :company => @user.company)
				@enrollment = Factory(:enrollment, :path => @path, :user => @user)
				test_sign_in(@user)
			end
			
			it "should destroy the enrollment" do
				lambda do
					delete :destroy, :id => @enrollment
				end.should change(Enrollment, :count).by(-1)
			end
		end
	end
end
	