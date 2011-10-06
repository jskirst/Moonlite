require 'spec_helper'

describe UsersController do
	render_views

	describe "Get 'show'" do
		before(:each) do
			@user = Factory(:user)
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
		
		it "Should have a gravatar inside the header" do
			get :show, :id => @user
			response.should have_selector("h1>img", :class => "gravatar")
		end
		
		it "should show the user's microposts" do
			mp1 = Factory(:micropost, :user => @user, :content => "Content1")
			mp2 = Factory(:micropost, :user => @user, :content => "Content2")
			get :show, :id => @user
			response.should have_selector("span", :content => mp1.content)
			response.should have_selector("span", :content => mp2.content)
		end
	end
	
	describe "GET 'new'" do
		it "should be successful" do
			get :new
			response.should be_success
		end

		it "should have right title" do
			get :new
			response.should have_selector("title", :content => "Sign up")
		end
	end
	
	describe "POST 'create'" do
		describe "Failure" do
			before(:each) do
				@attr = {:name => "", :email => "", :password => "", :password_confirmation => ""}
			end
			
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
				response.should render_template('new')
			end
		end
		
		describe "Success" do
			before(:each) do
				@attr = {:name => "Test", :email => "test@testing.com", :password => "testing", :password_confirmation => "testing"}
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
				flash[:success].should =~ /welcome to the sample app/i
			end
			
			it "Should sign the user in" do
				post :create, :user => @attr
				controller.should be_signed_in
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
			response.should have_selector("title", :content => "Edit")
		end
		
		it "should have have a link to change the gravatar" do
			get :edit, :id => @user
			gravatar_url = "http://www.gravatar.com/email"
			response.should have_selector("a", 
				:href => gravatar_url,
				:content => "Change")
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
				put :edit, :id => @user,  :user => @attr
				response.should render_template('edit')
			end
			
			it "should have the right title" do
				put :edit, :id => @user,  :user => @attr
				response.should have_selector("title", :content => "Edit")
			end
			
			# it "should have an error message" do
				# put :edit, :id => @user, :user => @attr
				# flash[:error].should =~ "Invalid"
			# end
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
