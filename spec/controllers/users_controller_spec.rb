require 'spec_helper'

describe UsersController do
	render_views

	before(:each) do
		@company = Factory(:company)
		@company_user = Factory(:company_user, :company => @company)
	end
	
	describe "GET 'accept'" do
		describe "with invalid token" do
			it "should redirect to root" do
				get :accept, :id => "XYZ"
				response.should redirect_to root_path
			end
		end
		
		describe "with valid token" do
			it "should be successful" do
				get :accept, :id => @company_user.token1
				response.should be_success
			end
			
			it "should render new" do
				get :accept, :id => @company_user.token1
				response.should render_template("new")
			end

			it "should have right title" do
				get :accept, :id => @company_user.token1
				response.should have_selector("title", :content => @company.name)
			end
		end
	end
	
	describe "POST 'create'" do
		describe "failure" do
			before(:each) do
				@attr = {:name => "", :password => "", :password_confirmation => "", :token1 => @company_user.token1}
			end
			
			describe "because of invalid token" do
				before(:each) do
					@attr = @attr.merge(:token1 => "XYZ")
				end
				
				it "should not be successful" do
					post :create, :user => @attr.delete("token1")
					response.should_not be_success
				end
				
				it "should should not create a user" do
					lambda do
						post :create, :user => @attr
					end.should_not change(User, :count)
				end
				
				it "should should redirect to root" do
					post :create, :user => @attr
					response.should redirect_to root_path
				end
			end
			
			describe "because of blank fields" do
				it "should not create a user" do
					lambda do
						post :create, :user => @attr
					end.should_not change(User, :count)
				end
				
				it "should have the right title" do
					post :create, :user => @attr
					response.should have_selector("title", :content => "Sign up")
				end
				
				it "should render the new page" do
					post :create, :user => @attr
					response.should render_template("new")
				end
			end
		end
		
		describe "success" do
			before(:each) do
				@attr = {:name => "Test", :password => "testing", :password_confirmation => "testing", :token1 => @company_user.token1}
			end
			
			it "Should save new user successfully" do
				lambda do
					post :create, :user => @attr
				end.should change(User, :count).by(1)
			end
			
			it "Should redirect to profile page" do
				post :create, :user => @attr
				response.should redirect_to(user_path(assigns(:user)))
			end
			
			it "Should have a welcome message" do
				post :create, :user => @attr
				flash[:success].should =~ /welcome to/i
			end
			
			it "Should sign the user in" do
				post :create, :user => @attr
				controller.should be_signed_in
			end
			
			it "should add user_id to company_user" do
				lambda do
					post :create, :user => @attr.merge(:token1 => @company_user.token1)
					@company_user.reload
				end.should change(@company_user, :user_id)
			end
		end
	end
	
	describe "Get 'show'" do
		before(:each) do
			@user = Factory(:user)
			test_sign_in(@user)
			@other_user = Factory(:user, :email => "other_user@email.com")
		end
		
		describe "failure" do
			describe "because of invalid id" do
				it "should redirect to root path" do
					get :show, :id => "abc"
					response.should redirect_to root_path
				end
			end
		end
		
		it "should be successful" do
			get :show, :id => @user
			response.should be_success
		end
		
		it "Should find the right user" do
			get :show, :id => @user
			assigns(:user).should == @user
		end
		
		it "Should have the user's name in the title" do
			get :show, :id => @user
			response.should have_selector("title", :content => @user.name)
		end
		
		it "Should have the user's name in the header" do
			get :show, :id => @user
			response.should have_selector("h1", :content => @user.name)
		end
		
		it "Should have a profile pic inside the header" do
			get :show, :id => @user
			response.should have_selector("h1>img", :class => "profile_pic")
		end
		
		describe "achievement details" do
			describe "when they do not exist" do
				it "should be replaced by a message saying they have none" do
					get :show, :id => @user
					response.should have_selector("p", :content => "not currently enrolled")
				end
			end
		
			describe "when they exist" do
				before(:each) do
					@path1 = Factory(:path, :user => @other_user, :name => "Name1")
					@path2 = Factory(:path, :user => @other_user, :name => "Name2")
					
					@enrollment1 = Factory(:enrollment, :path => @path1, :user => @user)
					@enrollment2 = Factory(:enrollment, :path => @path2, :user => @user)
					
					@task1_path1 = Factory(:task, :path => @path1, :points => 2)
					@user.award_points(@task1_path1)
					@task2_path1 = Factory(:task, :path => @path1, :points => 2)
					@user.award_points(@task2_path1)
					@task3_path1 = Factory(:task, :path => @path1, :points => 2)
					@user.award_points(@task3_path1)
					@path1_earned_points = 6
					
					@task1_path2 = Factory(:task, :path => @path2, :points => 7)
					@user.award_points(@task1_path2)
					@task2_path2 = Factory(:task, :path => @path2, :points => 7)
					@user.award_points(@task2_path2)
					@task3_path2 = Factory(:task, :path => @path2, :points => 7)
					@user.award_points(@task3_path2)
					@path2_earned_points = 21
					
					@completed_task1_path1 = Factory(:completed_task, :task => @task1_path1, :user => @user)
					@completed_task2_path1 = Factory(:completed_task, :task => @task2_path1, :user => @user)
					@completed_task1_path2 = Factory(:completed_task, :task => @task1_path2, :user => @user)
					@completed_task2_path2 = Factory(:completed_task, :task => @task2_path2, :user => @user)
					
					@total_earned_points = @path1_earned_points + @path2_earned_points
				end
				
				it "should show the user's paths" do
					get :show, :id => @user
					response.should have_selector("li", :content => @path1.name)
					response.should have_selector("li", :content => @path2.name)
				end
				
				it "should show the users total earned points" do
					get :show, :id => @user
					response.should have_selector("p", :content => "#{@total_earned_points}")
				end
				
				it "should show the users point total for each path" do
					get :show, :id => @user
					response.should have_selector("p", :content => "#{@path1_earned_points}")
					response.should have_selector("p", :content => "#{@path2_earned_points}")
				end
			end
		end
	end
	
	describe "GET 'edit'" do
		before(:each) do
			@user = Factory(:user)
			test_sign_in @user
		end
		
		it "should be successful" do
			get :edit, :id => @user
			response.should be_success
		end

		it "should have right title" do
			get :edit, :id => @user
			response.should have_selector("title", :content => "Settings")
		end
	end
	
	describe "PUT 'update'" do
		before(:each) do
			@user = Factory(:user)
			test_sign_in(@user)
		end
		
		describe "Failure" do
			before(:each) do
				@attr = {:name => "", 
				:email => "", 
				:password => "", 
				:password_confirmation => ""}
			end
			
			it "should render the edit page" do
				put :update, :id => @user,  :user => @attr
				response.should render_template('edit')
			end
			
			it "should have the right title" do
				put :update, :id => @user,  :user => @attr
				response.should have_selector("title", :content => "Settings")
			end
			
			it "should have an error message" do
				put :update, :id => @user, :user => @attr
				response.should have_selector("div", :id => "error_explanation")
			end
		end
		
		describe "Success" do
			before(:each) do
				@attr = {:name => "EditTest", 
				:email => "edittest@testing.com", 
				:password => "edittesting", 
				:password_confirmation => "edittesting"}
			end
			
			it "Should change user successfully" do
				put :update, :id => @user, :user => @attr
				@user.reload
				@user.name.should == @attr[:name]
				@user.email.should == @attr[:email]
				#CANNOT TEST PASSWORD CHANGE
			end
			
			it "Should redirect to profile page" do
				put :update, :id => @user, :user => @attr
				response.should redirect_to(user_path(assigns(:user)))
			end
			
			it "Should have a success message" do
				put :update, :id => @user, :user => @attr
				flash[:success].should =~ /updated/i
			end
		end
	end
	
	describe "authentication of edit/update pages" do
		before(:each) do
			@user = Factory(:user)
		end
		
		describe "for non-signed-in users" do
			it "should deny access to 'edit'" do
				get :edit, :id => @user, :user => {}
				response.should redirect_to(signin_path)
			end
			
			it "should deny access to 'update'" do
				put :update, :id => @user, :user => {}
				response.should redirect_to(signin_path)
			end
		end
		
		describe "for signed-in users" do
			before(:each) do
				wrong_user = Factory(:user, :email => "wronguser@testing.com")
				test_sign_in(wrong_user)
			end
		
			it "should require matching user to 'edit'" do
				put :update, :id => @user, :user => {}
				response.should redirect_to(root_path)
			end
			
			it "should require matching user to 'update'" do
				put :update, :id => @user, :user => {}
				response.should redirect_to(root_path)
			end
		end
	end

	describe "GET 'index'" do
		describe "for non-signed-in users" do
			it "should deny access" do
				get :index
				response.should redirect_to(signin_path)
				flash[:notice].should =~ /sign in/i
			end
		end
		
		describe "for signed_in users" do
			before(:each) do
				@user = test_sign_in(Factory(:user))
				user1 = Factory(:user, :email => "indextest1@testing.com")
				user2 = Factory(:user, :email => "indextest2@testing.com")
				@users = [@user, user1, user2]
				
				30.times do
					@users << Factory(:user, :email => Factory.next(:email))
				end
			end
			
			describe "as a non-admin user" do
				it "should protect the page" do
					get :index
					response.should redirect_to(root_path)
				end
			end
			
			describe "as an admin user" do
				before(:each) do
					admin = Factory(:user, 
						:email => "admin@testing.com", 
						:admin => true)
					test_sign_in(admin)
				end
				
				it "should be successful" do
					get :index
					response.should be_success
				end
				
				it "should have the right title" do
					get :index
					response.should have_selector("title", :content => "All users")
				end
				
				it "should display all users" do
					get :index
					@users[0..2].each do |u|
						response.should have_selector("li", :content => u.name)
					end
				end
				
				it "should paginate users" do
					get :index
					response.should have_selector("div.pagination")
					response.should have_selector("span.disabled", :content => "Previous")
					response.should have_selector("a", :href => "/users?page=2", :content => "2")
				end
			end
		end
	end
	
	describe "DELETE 'destroy'" do
		before(:each) do
			@user = Factory(:user)
		end
		
		describe "as a non-signed-in user" do
			it "should redirect to root" do
				delete :destroy, :id => @user
				response.should redirect_to(signin_path)
			end
		end
		
		describe "as a non-admin user" do
			it "should protect the page" do
				test_sign_in(@user)
				delete :destroy, :id => @user
				response.should redirect_to(root_path)
			end
		end
		
		describe "as an admin user" do
			before(:each) do
				admin = Factory(:user, 
					:email => "admin@testing.com", 
					:admin => true)
				test_sign_in(admin)
			end
			
			it "should destroy the user" do
				lambda do
					delete :destroy, :id => @user
				end.should change(User, :count).by(-1)
			end
			
			it "should redirect to users page" do
				delete :destroy, :id => @user
				response.should redirect_to(users_path)
			end
		end
	end
end
