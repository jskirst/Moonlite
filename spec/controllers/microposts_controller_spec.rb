require 'spec_helper'

describe MicropostsController do
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
			test_sign_in(@user)
		end
		
		describe "failure" do
			before(:each) do
				@attr = { :content => "" }
			end
		
			it "should not create a micropost" do
				lambda do
					post :create, :micropost => @attr  
				end.should_not change(Micropost, :count)
			end
			
			it "should redirect you to the home page" do
				post :create, :micropost => @attr
				response.should render_template('pages/home')
			end
		end
		
		describe "success" do
			before(:each) do
				@attr = { :content => "Lorem Ipsum" }
			end
			
			it "should create a post" do
				lambda do
					post :create, :micropost => @attr
				end.should change(Micropost, :count).by(1)		
			end
			
			it "should redirect to the home page" do
				post :create, :micropost => @attr
				response.should redirect_to(root_path)
			end
			
			it "should have a flash message" do
				post :create, :micropost => @attr
				flash[:success].should =~ /micropost created/i
			end
		end
	end
	
	describe "DELETE 'destroy'" do
		describe "as an unauthorized user" do
			before(:each) do
				@user = Factory(:user)
				@micropost = Factory(:micropost, :user => @user)
				
				@other_user = Factory(:user, :email => "other@o.com")
				test_sign_in(@other_user)
			end
			
			it "should deny access" do
				delete :destroy, :id => @micropost
				response.should redirect_to(root_path)
			end
		end
		
		describe "as an authorized user" do
			before(:each) do
				@user = test_sign_in(Factory(:user))
				@micropost = Factory(:micropost, :user => @user)
			end
			
			it "should destroy the micropost" do
				lambda do
					delete :destroy, :id => @micropost
				end.should change(Micropost, :count).by(-1)
			end
		end
	end
end
	