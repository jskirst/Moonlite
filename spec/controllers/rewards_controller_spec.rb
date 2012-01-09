require 'spec_helper'

describe RewardsController do
	render_views
	
	before(:each) do
		@user = Factory(:user)
		@company = Factory(:company)
		@attr = { :company_id => @company.id,
			:name => "Fubar",
			:description => "Fucked up beyond all recognition",
			:image_url => "http://www.o.co/face",
			:points => 5}
	end
	
	describe "access controller" do
		before(:each) do
			@reward = @company.rewards.create!(@attr)
		end
	
		describe "when not signed in" do
			it "should deny access to 'new'" do
				get :new, :company_id => @company
				response.should redirect_to signin_path
			end
		
			it "should deny access to 'create'" do
				post :create, :reward => @attr
				response.should redirect_to signin_path
			end
			
			it "should deny access to 'index'" do
				get :index, :company_id => @company
				response.should redirect_to signin_path
			end
			
			it "should deny access to 'show'" do
				get :show, :id => @reward
				response.should redirect_to signin_path
			end
			
			it "should deny access to 'edit'" do
				get :edit, :id => @reward
				response.should redirect_to signin_path
			end

			it "should deny access to 'update'" do
				put :update, :id => @reward, :reward => @attr
				response.should redirect_to signin_path
			end			
		end
		
		describe "when signed in as a regular user" do
			before(:each) do
				@company_user = Factory(:company_user, :company => @company, :user => @user)
				test_sign_in(@user)
			end
			
			it "should deny access to 'new'" do
				get :new, :company_id => @company.id
				response.should redirect_to root_path
			end
		
			it "should deny access to 'create'" do
				post :create, :reward => @attr
				response.should redirect_to root_path
			end
			
			it "should allow access to 'index'" do
				get :index, :company_id => @company.id
				response.should_not redirect_to root_path
				response.should_not redirect_to @user
				response.should be_success
			end
			
			it "should allow access to 'show'" do
				get :show, :id => @reward
				response.should_not redirect_to root_path
				response.should_not redirect_to @user
				response.should be_success
			end
			
			it "should deny access to 'edit'" do
				get :edit, :id => @reward
				response.should redirect_to root_path
			end
			
			it "should deny access to 'update'" do
				put :update, :id => @reward, :reward => @attr
				response.should redirect_to root_path
			end		
		end
		
		describe "when signed in as company admin" do
			before(:each) do
				@company_user = Factory(:company_user, :company => @company, :user => @user, :is_admin => "t")
				test_sign_in(@user)
			end
			
			it "should allow access to 'new'" do
				get :new, :company_id => @company.id
				response.should_not redirect_to root_path
				response.should_not redirect_to @user
				response.should  be_success
			end
		
			it "should allow access to 'create'" do
				post :create, :reward => @attr
				response.should_not redirect_to root_path
				response.should_not redirect_to @user
				response.should redirect_to Reward.find(2)
			end
			
			it "should allow access to 'index'" do
				get :index, :company_id => @company
				response.should_not redirect_to root_path
				response.should_not redirect_to @user
				response.should be_success
			end
			
			it "should allow access to 'show'" do
				get :show, :id => @reward
				response.should_not redirect_to root_path
				response.should_not redirect_to @user
				response.should be_success
			end
			
			it "should allow access to 'edit'" do
				get :edit, :id => @reward
				response.should_not redirect_to root_path
				response.should_not redirect_to @user
				response.should be_success
			end
			
			it "should allow access to 'update'" do
				put :update, :id => @reward, :reward => @attr
				response.should redirect_to @reward
			end
		end
		
		describe "when signed in as admin" do
			before(:each) do
				@user.toggle!(:admin)
				test_sign_in(@user)
			end
			
			it "should allow access to 'new'" do
				get :new, :company_id => @company
				response.should_not redirect_to root_path
				response.should_not redirect_to @user
				response.should be_success
			end
		
			it "should allow access to 'create'" do
				post :create, :reward => @attr
				response.should_not redirect_to root_path
				response.should_not redirect_to @user
				response.should redirect_to Reward.find(2)
			end
			
			it "should allow access to 'index'" do
				get :index, :company_id => @company
				response.should_not redirect_to root_path
				response.should_not redirect_to @user
				response.should be_success
			end
			
			it "should allow access to 'show'" do
				get :show, :id => @reward
				response.should_not redirect_to root_path
				response.should_not redirect_to @user
				response.should be_success
			end
			
			it "should allow access to 'edit'" do
				get :edit, :id => @reward
				response.should_not redirect_to root_path
				response.should_not redirect_to @user
				response.should be_success
			end
			
			it "should allow access to 'update'" do
				put :update, :id => @reward, :reward => @attr
				response.should redirect_to @reward
			end
		end
	end
	
	describe "action" do
		before(:each) do
			@user = Factory(:user)
			@company_user = Factory(:company_user, :user => @user, :company => @company, :is_admin => "t")
			@reward = Factory(:reward, :company => @company)
			test_sign_in(@user)
		end
	
		describe "Get 'show'" do
			it "should be successful" do
				get :show, :id => @reward
				response.should be_success
			end
			
			it "Should find the right task" do
				get :show, :id => @reward
				assigns(:reward).should == @reward
			end
			
			it "Should have the path's name in the title" do
				get :show, :id => @reward
				response.should have_selector("title", :content => @reward.name)
			end
			
			it "should display the description" do
				get :show, :id => @reward
				response.should have_selector("p", :content => @reward.description)
			end
			
			it "should display the point cost" do
				get :show, :id => @reward
				response.should have_selector("p", :content => @reward.points.to_s)
			end
		end
		
		describe "GET 'new'" do
			it "should be successful" do
				get :new, :company_id => @company
				response.should be_success
			end

			it "should have right title" do
				get :new, :company_id => @company
				response.should have_selector("title", :content => "New")
			end
		end
		
		describe "POST 'create'" do
			describe "failure" do
				before(:each) do
					@attr = { :name => "", :description => "", :image_url => "", :points => "", :company_id => @company.id }
				end
			
				it "should not create a reward" do
					lambda do
						post :create, :reward => @attr
					end.should_not change(Reward, :count)
				end
				
				it "should take you back to the new reward page" do
					post :create, :reward => @attr
					response.should render_template("rewards/reward_form")
				end
			end
			
			describe "success" do
				before(:each) do
					@attr = { :name => "Test Name", 
					:description => "Test Description", 
					:image_url => "http://www.google.com", 
					:points => 5000, 
					:company_id => @company.id }
				end
				
				it "should create a reward" do
					lambda do
						post :create, :reward => @attr
					end.should change(Reward, :count).by(1)
				end
				
				it "should redirect to the reward page" do
					post :create, :reward => @attr
					response.should redirect_to(Reward.last)
				end
				
				it "should have a flash message" do
					post :create, :reward => @attr
					flash[:success].should =~ /reward created/i
				end
			end
		end
		
		describe "GET 'edit'" do
			it "should be successful" do
				get :edit, :id => @reward
				response.should be_success
			end

			it "should have right title" do
				get :edit, :id => @reward
				response.should have_selector("title", :content => "Edit")
			end
			
			it "should have the right name" do
				get :edit, :id => @reward
				response.should have_selector("input", :value => @reward.name)
			end
		end
		
		describe "PUT 'update'" do
			describe "Failure" do
				before(:each) do
					@attr = { :name => "", :description => "", :image_url => "", :points => "", :company_id => @company.id.to_s }
				end
				
				it "should render the edit page" do
					put :update, :id => @reward, :reward => @attr
					response.should render_template("rewards/reward_form")
				end
				
				it "should have the right title" do
					put :update, :id => @reward, :reward => @attr
					response.should have_selector("title", :content => "Edit")
				end
				
				it "should have an error message" do
					put :update, :id => @reward, :reward => @attr
					response.should have_selector("p", :content => "The were problems with the following fields")
				end
			end
			
			describe "Success" do
				before(:each) do
					@attr = { :name => "Changed Test Name", 
						:description => "Changed Test Description", 
						:image_url => "Changed http://www.google.com", 
						:points => 100, 
						:company_id => @company.id }
				end
				
				it "Should change the reward successfully" do
					put :update, :id => @reward, :reward => @attr
					@reward.reload
					@reward.name.should == @attr[:name]
					@reward.description.should == @attr[:description]
					@reward.points.should == @attr[:points]
				end
				
				it "Should redirect to reward page" do
					put :update, :id => @reward, :reward => @attr
					response.should redirect_to(reward_path(assigns(:reward)))
				end
				
				it "Should have a success message" do
					put :update, :id => @reward, :reward => @attr
					flash[:success].should =~ /updated/i
				end
			end
		end
		
		# describe "DELETE 'destroy'" do
			# describe "as an unauthorized user" do
				# before(:each) do
					# @user = Factory(:user)
					# @path = Factory(:path, :user => @user)
					# @task = Factory(:task, :path => @path)
					
					# @other_user = Factory(:user, :email => "other@o.com")
					# test_sign_in(@other_user)
				# end
				
				# it "should deny access" do
					# delete :destroy, :id => @task
					# response.should redirect_to(root_path)
				# end
			# end
			
			# describe "as an authorized user" do
				# before(:each) do
					# @user = test_sign_in(Factory(:user))
					# @path = Factory(:path, :user => @user)
					# @task = Factory(:task, :path => @path)
				# end
				
				# it "should destroy the task" do
					# lambda do
						# delete :destroy, :id => @task
					# end.should change(Task, :count).by(-1)
				# end
			# end
		# end
	end
end