require 'spec_helper'

describe UsersController do
	render_views

	before(:each) do
		@company = Factory(:company)
		@attr = {:email => "test@t.com", :company_id => @company.id}
	end
	
	# describe "GET 'new'" do
		# before(:each) do
			# @user = Factory(:user, :company_admin => true)
			# test_sign_in @user
		# end
	
		# it "should be successful" do
			# get :new, :company_id => @company.id
			# response.should be_success
		# end
	# end
	
	describe "POST 'create'" do
		before(:each) do
			@user = Factory(:user, :company => @company, :company_admin => true)
			test_sign_in @user
		end
		
		describe "failure" do
			describe "because of invalid company id" do
				before(:each) do
					@attr = @attr.merge(:company_id => "abc")
				end
				
				it "should not be successful" do
					post :create, :user => @attr
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
			
			describe "because of invalid email" do
				before(:each) do
					@attr = @attr.merge(:email => "")
				end
				
				it "should not create a user" do
					lambda do
						post :create, :user => @attr
					end.should_not change(User, :count)
				end
				
				it "should have the right title" do
					post :create, :user => @attr
					response.should have_selector("title", :content => "Invite user")
				end
				
				it "should render the new page" do
					post :create, :user => @attr
					response.should render_template("new")
				end
			end
		end
		
		describe "success" do
			it "should save new user successfully" do
				lambda do
					post :create, :user => @attr
				end.should change(User, :count).by(1)
			end
			
			it "should redirect to company page" do
				post :create, :user => @attr
				response.should redirect_to @company
			end
			
			it "should have a success message" do
				post :create, :user => @attr
				flash[:success].should =~ /success/i
			end
		end
	end
	
	# describe "GET 'accept'" do
		# before(:each) do
			# @user = Factory(:user, :name => "pending")
		# end
	
		# describe "with invalid token" do
			# it "should redirect to root" do
				# get :accept, :id => "XYZ"
				# response.should redirect_to root_path
			# end
		# end
		
		# describe "with valid token" do
			# it "should be successful" do
				# get :accept, :id => @user.signup_token
				# response.should be_success
			# end
			
			# it "should render new" do
				# get :accept, :id => @user.signup_token
				# response.should render_template("accept")
			# end

			# it "should have right title" do
				# get :accept, :id => @user.signup_token
				# response.should have_selector("title", :content => @company.name)
			# end
		# end
	# end
	
	# describe "PUT 'join'" do
		# before(:each) do
			# @user = Factory(:user, :company => @company, :name => "pending")
		# end
	
		# describe "failure" do
			# before(:each) do
				# @attr = {:name => "", 
					# :password => "", 
					# :password_confirmation => "", 
					# :image_url => "", 
					# :signup_token => @user.signup_token}
			# end
			
			# describe "because of invalid token" do
				# it "should not be successful" do
					# put :join, :id => @user.signup_token, :user => @attr.delete("signup_token")
					# response.should_not be_success
				# end
				
				# it "should should redirect to root" do
					# put :join, :id => @user.signup_token, :user => @attr.delete("signup_token")
					# response.should redirect_to root_path
				# end
			# end
			
			# describe "because of blank fields" do
				# it "should not create a user" do
					# lambda do
						# put :join, :id => @user.signup_token, :user => @attr
					# end.should_not change(User, :count)
				# end
				
				# it "should have the right title" do
					# put :join, :id => @user.signup_token, :user => @attr
					# response.should have_selector("title", :content => "Accept invite")
				# end
				
				# it "should render the new page" do
						# put :join, :id => @user.signup_token, :user => @attr
					# response.should render_template("accept")
				# end
			# end
		# end
		
		# describe "success" do
			# before(:each) do
				# @attr = {:name => "Test", 
					# :password => "testing", 
					# :password_confirmation => "testing",
					# :signup_token => @user.signup_token}
			# end
			
			# it "should redirect to profile page" do
				# put :join, :id => @user.signup_token, :user => @attr
				# response.should redirect_to @user
			# end
			
			# it "should have a welcome message" do
				# put :join, :id => @user.signup_token, :user => @attr
				# flash[:success].should =~ /welcome to/i
			# end
			
			# it "should sign the user in" do
				# put :join, :id => @user.signup_token, :user => @attr
				# controller.should be_signed_in
			# end
			
			# it "should change name to proper name" do
				# lambda do
					# put :join, :id => @user.signup_token, :user => @attr
					# @user.reload
				# end.should change(@user, :name)
			# end
		# end
	# end
	
	describe "Get 'show'" do
		before(:each) do
			@user = Factory(:user)
			test_sign_in(@user)
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
		
		it "should find the right user" do
			get :show, :id => @user
			assigns(:user).should == @user
		end
		
		it "should have the user's name in the title" do
			get :show, :id => @user
			response.should have_selector("title", :content => @user.name)
		end
		
		it "should have the user's name in the header" do
			get :show, :id => @user
			response.should have_selector("h1", :content => @user.name)
		end
		
		it "should have a profile pic inside the header" do
			get :show, :id => @user
			response.should have_selector("img", :class => "profile_pic")
		end
		
		describe "achievement details" do
			describe "when they do not exist" do
				it "should be replaced by a message saying they have none" do
					get :show, :id => @user
					response.should have_selector("p", :content => "not currently enrolled")
				end
			end
		
			# describe "when they exist" do
				# before(:each) do
					# @path1 = Factory(:path, :user => @other_user, :name => "Name1")
					# @path2 = Factory(:path, :user => @other_user, :name => "Name2")
					
					# @enrollment1 = Factory(:enrollment, :path => @path1, :user => @user)
					# @enrollment2 = Factory(:enrollment, :path => @path2, :user => @user)
					
					# @task1_path1 = Factory(:task, :path => @path1, :points => 2)
					# @user.award_points(@task1_path1)
					# @task2_path1 = Factory(:task, :path => @path1, :points => 2)
					# @user.award_points(@task2_path1)
					# @task3_path1 = Factory(:task, :path => @path1, :points => 2)
					# @user.award_points(@task3_path1)
					# @path1_earned_points = 6
					
					# @task1_path2 = Factory(:task, :path => @path2, :points => 7)
					# @user.award_points(@task1_path2)
					# @task2_path2 = Factory(:task, :path => @path2, :points => 7)
					# @user.award_points(@task2_path2)
					# @task3_path2 = Factory(:task, :path => @path2, :points => 7)
					# @user.award_points(@task3_path2)
					# @path2_earned_points = 21
					
					# @completed_task1_path1 = Factory(:completed_task, :task => @task1_path1, :user => @user)
					# @completed_task2_path1 = Factory(:completed_task, :task => @task2_path1, :user => @user)
					# @completed_task1_path2 = Factory(:completed_task, :task => @task1_path2, :user => @user)
					# @completed_task2_path2 = Factory(:completed_task, :task => @task2_path2, :user => @user)
					
					# @total_earned_points = @path1_earned_points + @path2_earned_points
				# end
				
				# it "should show the user's paths" do
					# get :show, :id => @user
					# response.should have_selector("td", :content => @path1.name)
					# response.should have_selector("td", :content => @path2.name)
				# end
				
				# it "should show the users total earned points" do
					# get :show, :id => @user
					# response.should have_selector("p", :content => "#{@total_earned_points}")
				# end
				
				# it "should show the users point total for each path" do
					# get :show, :id => @user
					# response.should have_selector("p", :content => "#{@path1_earned_points}")
					# response.should have_selector("p", :content => "#{@path2_earned_points}")
				# end
			# end
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
		
		describe "failure" do
			before(:each) do
				@attr = {:name => "", 
				:email => "", 
				:password => "",
				:image_url => "",
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
		
		describe "success" do
			before(:each) do
				@attr = {:name => "EditTest", 
				:email => "edittest@testing.com", 
				:password => "edittesting",
				:image_url => "http://placehold.it/210x150",
				:password_confirmation => "edittesting"}
			end
			
			it "should change user successfully" do
				put :update, :id => @user, :user => @attr
				@user.reload
				@user.name.should == @attr[:name]
				@user.email.should == @attr[:email]
				#CANNOT TEST PASSWORD CHANGE
			end
			
			it "should redirect to profile page" do
				put :update, :id => @user, :user => @attr
				response.should redirect_to(user_path(assigns(:user)))
			end
			
			it "should have a success message" do
				put :update, :id => @user, :user => @attr
				flash[:success].should =~ /updated/i
			end
			
			it "should return profile pic set in image_url" do
				put :update, :id => @user, :user => @attr
				@user.reload
				@user.profile_pic.should == @attr[:image_url]
			end
		end
	end
	
	describe "DELETE 'destroy'" do
		before(:each) do
			@user = Factory(:user)
			@user.toggle!(:company_admin)
			@other_user = Factory(:user, :company => @user.company)
			test_sign_in(@user)
		end
		
		it "should destroy the user" do
			lambda do
				delete :destroy, :id => @other_user
			end.should change(User, :count).by(-1)
		end
		
		it "should redirect to users page" do
			delete :destroy, :id => @other_user
			response.should redirect_to @user.company
		end
	end
end
