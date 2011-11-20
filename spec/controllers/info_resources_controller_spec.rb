require 'spec_helper'

describe InfoResourcesController do
	render_views
	
	before(:each) do
		@good_attr = {
			:description => "Replacement description", 
			:link => "http://www.testlink.com", 
			:path_id => 1
		}
		@empty_attr = { 
			:description => "", 
			:link => "", 
			:path_id => 1
		}
	end
	
	describe "access controller" do
		it "should deny access to 'new'" do
			get :new, :path_id => 1
			response.should redirect_to(signin_path)
		end
		
		it "should deny access to 'edit'" do
			get :edit, :id => 1
			response.should redirect_to(signin_path)
		end
		
		it "should deny access to 'show'" do
			get :show, :id => 1
			response.should redirect_to(signin_path)
		end
	
		it "should deny access to 'create'" do
			post :create
			response.should redirect_to(signin_path)
		end
		
		it "should deny access to 'delete'" do
			delete :destroy, :id => 1
			response.should redirect_to(signin_path)
		end
	end
	
	describe "GET 'new'" do
		before(:each) do
			@user = Factory(:user)
			@path = Factory(:path, :user => @user)
			test_sign_in(@user)
		end
		
		it "should be successful" do
			get :new, :path => @path
			response.should be_success
		end

		it "should have right title" do
			get :new, :path => @path
			response.should have_selector("title", :content => "New Resource")
		end
	end
	
	describe "POST 'create'" do
		before(:each) do
			@user = Factory(:user)
			@path = Factory(:path, :user => @user)
			test_sign_in(@user)
		end
		
		describe "failure" do
			before(:each) do
				@attr = @empty_attr
			end
		
			it "should not create a info_resource" do
				lambda do
					post :create, :info_resource => @attr  
				end.should_not change(Path, :count)
			end
			
			it "should take you back to the new info_resource page" do
				post :create, :info_resource => @attr
				response.should render_template("info_resources/info_resource_form")
			end
		end
		
		describe "success" do
			before(:each) do
				@attr = @good_attr
			end
			
			it "should create a info_resource" do
				lambda do
					post :create, :info_resource => @attr
				end.should change(InfoResource, :count).by(1)		
			end
			
			it "should redirect to the path page" do
				post :create, :info_resource => @attr
				response.should redirect_to(@path)
			end
			
			it "should have a flash message" do
				post :create, :info_resource => @attr
				flash[:success].should =~ /resource created/i
			end
		end
	end
	
	describe "Get 'show'" do
		before(:each) do
			@user = Factory(:user)
			@path = Factory(:path, :user => @user)
			@info_resource = Factory(:info_resource, :path => @path)
			test_sign_in(@user)
		end
		
		it "should be successful" do
			get :show, :id => @info_resource
			response.should be_success
		end
		
		it "Should find the right info_resource" do
			get :show, :id => @info_resource
			assigns(:info_resource).should == @info_resource
		end
		
		it "Should have the path's name in the title" do
			get :show, :id => @info_resource
			response.should have_selector("title", :content => @path.name)
		end
		
		it "should display the description" do
			get :show, :id => @info_resource
			response.should have_selector("p", :content => @info_resource.description)
		end
		
		it "should display the link" do
			get :show, :id => @info_resource
			response.should have_selector("p", :content => @info_resource.link)
		end
	end
	
	describe "GET 'edit'" do
		before(:each) do
			@user = Factory(:user)
			@path = Factory(:path, :user => @user)
			@info_resource = Factory(:info_resource, :path => @path)
			test_sign_in @user
		end
		
		it "should be successful" do
			get :edit, :id => @info_resource
			response.should be_success
		end

		it "should have right title" do
			get :edit, :id => @info_resource
			response.should have_selector("title", :content => "Edit")
		end
	end
	
	describe "PUT 'update'" do
		before(:each) do
			@user = Factory(:user)
			@path = Factory(:path, :user => @user)
			@info_resource = Factory(:info_resource, :path => @path)
			test_sign_in(@user)
		end
		
		describe "Failure" do
			before(:each) do
				@attr = @empty_attr
			end
			
			it "should render the edit page" do
				put :update, :id => @info_resource, :info_resource => @attr
				response.should render_template("info_resources/info_resource_form")
			end
			
			it "should have the right title" do
				put :update, :id => @info_resource, :info_resource => @attr
				response.should have_selector("title", :content => "Edit")
			end
			
			it "should have an error message" do
				put :update, :id => @info_resource, :info_resource => @attr
				response.should have_selector("p", :content => "The were problems with the following fields")
			end
		end
		
		describe "Success" do
			before(:each) do
				@attr = @good_attr
			end
			
			it "Should change info_resource successfully" do
				put :update, :id => @info_resource, :info_resource => @attr
				@info_resource.reload
				@info_resource.description.should == @attr[:description]
				@info_resource.link.should == @attr[:link]
			end
			
			it "Should redirect to info_resource page" do
				put :update, :id => @info_resource, :info_resource => @attr
				response.should redirect_to(info_resource_path(assigns(:info_resource)))
			end
			
			it "Should have a success message" do
				put :update, :id => @info_resource, :info_resource => @attr
				flash[:success].should =~ /updated/i
			end
		end
	end
	
	describe "DELETE 'destroy'" do
		describe "as an unauthorized user" do
			before(:each) do
				@user = Factory(:user)
				@path = Factory(:path, :user => @user)
				@info_resource = Factory(:info_resource, :path => @path)
				
				@other_user = Factory(:user, :email => "other@o.com")
				test_sign_in(@other_user)
			end
			
			it "should deny access" do
				delete :destroy, :id => @info_resource
				response.should redirect_to(root_path)
			end
		end
		
		describe "as an authorized user" do
			before(:each) do
				@user = test_sign_in(Factory(:user))
				@path = Factory(:path, :user => @user)
				@info_resource = Factory(:info_resource, :path => @path)
			end
			
			it "should destroy the info_resource" do
				lambda do
					delete :destroy, :id => @info_resource
				end.should change(InfoResource, :count).by(-1)
			end
		end
	end
end
	