# require 'spec_helper'

# describe RewardsController do
	# render_views
	
	# before(:each) do
		# @reward_points = 1000
		# @user = FactoryGirl.create(:user, :earned_points => @reward_points + 10, :spent_points => 10)
		# @company = @user.company
		# @attr = { :company_id => @company.id,
			# :name => "Fubar",
			# :description => "Fucked up beyond all recognition",
			# :image_url => "http://www.o.co/face",
			# :points => @reward_points}
	# end
	
	# describe "access controller" do
		# before(:each) do
			# @reward = @company.rewards.create!(@attr)
		# end
	
		# describe "when not signed in" do
			# it "should deny access to 'new'" do
				# get :new, :company_id => @company
				# response.should redirect_to signin_path
			# end
		
			# it "should deny access to 'create'" do
				# post :create, :reward => @attr
				# response.should redirect_to signin_path
			# end
			
			# it "should deny access to 'index'" do
				# get :index, :company_id => @company
				# response.should redirect_to signin_path
			# end
			
			# it "should deny access to 'show'" do
				# get :show, :id => @reward
				# response.should redirect_to signin_path
			# end
			
			# it "should deny access to 'edit'" do
				# get :edit, :id => @reward
				# response.should redirect_to signin_path
			# end

			# it "should deny access to 'update'" do
				# put :update, :id => @reward, :reward => @attr
				# response.should redirect_to signin_path
			# end
			
			# it "should deny access to 'review'" do
				# get :review, :id => @reward
				# response.should redirect_to signin_path
			# end
			
			# it "should deny access to 'purchase'" do
				# get :purchase, :id => @reward
				# response.should redirect_to signin_path
			# end

			# it "should deny access to 'destroy'" do
				# delete :destroy, :id => @reward
				# response.should redirect_to signin_path
			# end				
		# end
		
		# describe "when signed in as a regular user" do
			# before(:each) do
				# test_sign_in(@user)
			# end
			
			# describe "when company store is disabled" do
				# before(:each) do
					# @user.company.enable_company_store = false
					# @user.company.save!
				# end
				
				# it "should categorically deny access" do
					# get :index, :company_id => @company.id
					# response.should redirect_to root_path
				# end
			# end
			
			# it "should deny access to 'new'" do
				# get :new, :company_id => @company.id
				# response.should redirect_to root_path
			# end
		
			# it "should deny access to 'create'" do
				# post :create, :reward => @attr
				# response.should redirect_to root_path
			# end
			
			# it "should allow access to 'index'" do
				# get :index, :company_id => @company.id
				# response.should_not redirect_to root_path
				# response.should_not redirect_to @user
				# response.should be_success
			# end
			
			# it "should allow access to 'show'" do
				# get :show, :id => @reward
				# response.should_not redirect_to root_path
				# response.should_not redirect_to @user
				# response.should be_success
			# end
			
			# it "should deny access to 'edit'" do
				# get :edit, :id => @reward
				# response.should redirect_to root_path
			# end
			
			# it "should deny access to 'update'" do
				# put :update, :id => @reward, :reward => @attr
				# response.should redirect_to root_path
			# end
			
			# it "should allow access to 'review'" do
				# get :review, :id => @reward
				# response.should be_success
			# end
			
			# it "should allow access to 'purchase'" do
				# get :purchase, :id => @reward
				# response.should be_success
			# end
			
			# it "should deny access to 'destroy'" do
				# delete :destroy, :id => @reward
				# response.should redirect_to root_path
			# end	
		# end
		
		# describe "when signed in as company admin" do
			# before(:each) do
				# @user.set_company_admin(true)
				# test_sign_in(@user)
			# end
			
			# describe "when company store is disabled" do
				# before(:each) do
					# @user.company.enable_company_store = false
					# @user.company.save!
				# end
				
				# it "should categorically deny access" do
					# get :index, :company_id => @company.id
					# response.should redirect_to root_path
				# end
			# end
			
			# it "should allow access to 'new'" do
				# get :new, :company_id => @company.id
				# response.should_not redirect_to root_path
				# response.should_not redirect_to @user
				# response.should  be_success
			# end
		
			# it "should allow access to 'create'" do
				# post :create, :reward => @attr
				# response.should_not redirect_to root_path
				# response.should_not redirect_to @user
				# response.should redirect_to Reward.find(2)
			# end
			
			# it "should allow access to 'index'" do
				# get :index, :company_id => @company
				# response.should_not redirect_to root_path
				# response.should_not redirect_to @user
				# response.should be_success
			# end
			
			# it "should allow access to 'show'" do
				# get :show, :id => @reward
				# response.should_not redirect_to root_path
				# response.should_not redirect_to @user
				# response.should be_success
			# end
			
			# it "should allow access to 'edit'" do
				# get :edit, :id => @reward
				# response.should_not redirect_to root_path
				# response.should_not redirect_to @user
				# response.should be_success
			# end
			
			# it "should allow access to 'update'" do
				# put :update, :id => @reward, :reward => @attr
				# response.should redirect_to @reward
			# end
			
			# it "should allow access to 'review'" do
				# get :review, :id => @reward
				# response.should be_success
			# end
			
			# it "should allow access to 'purchase'" do
				# get :purchase, :id => @reward
				# response.should be_success
			# end
			
			# it "should allow access to 'destroy'" do
				# delete :destroy, :id => @reward
				# response.should_not redirect_to root_path
			# end	
		# end
		
		# describe "when signed in as admin" do
			# it "should deny access to 'new'" do
				# get :new, :company_id => @company
				# response.should redirect_to signin_path
			# end
		
			# it "should deny access to 'create'" do
				# post :create, :reward => @attr
				# response.should redirect_to signin_path
			# end
			
			# it "should deny access to 'index'" do
				# get :index, :company_id => @company
				# response.should redirect_to signin_path
			# end
			
			# it "should deny access to 'show'" do
				# get :show, :id => @reward
				# response.should redirect_to signin_path
			# end
			
			# it "should deny access to 'edit'" do
				# get :edit, :id => @reward
				# response.should redirect_to signin_path
			# end

			# it "should deny access to 'update'" do
				# put :update, :id => @reward, :reward => @attr
				# response.should redirect_to signin_path
			# end
			
			# it "should deny access to 'review'" do
				# get :review, :id => @reward
				# response.should redirect_to signin_path
			# end
			
			# it "should deny access to 'purchase'" do
				# get :purchase, :id => @reward
				# response.should redirect_to signin_path
			# end

			# it "should deny access to 'destroy'" do
				# delete :destroy, :id => @reward
				# response.should redirect_to signin_path
			# end	
		# end
	# end
	
	# describe "action" do
		# before(:each) do
			# @user.set_company_admin(true)
			# @reward_points = 1000
			# @reward = FactoryGirl.create(:reward, :company => @company, :points => @reward_points)
			# test_sign_in(@user)
		# end
	
		# describe "Get 'show'" do
			# describe "failure" do
				# describe "because of bad reward argument" do
					# it "should redirect to root path" do
						# get :show, :id => "abc"
						# response.should redirect_to root_path
					# end
				# end
				
				# describe "because reward does not belong to user's company" do
					# it "should redirect to root path" do
						# other_company = FactoryGirl.create(:company)
						# other_reward = FactoryGirl.create(:reward, :company => other_company)
						# get :show, :id => other_reward.id
						# response.should redirect_to @user
					# end
				# end
			# end
			
			# describe "success" do
				# it "should be successful" do
					# get :show, :id => @reward
					# response.should be_success
				# end
				
				# it "Should find the right task" do
					# get :show, :id => @reward
					# assigns(:reward).should == @reward
				# end
				
				# it "Should have the path's name in the title" do
					# get :show, :id => @reward
					# response.should have_selector("title", :content => @reward.name)
				# end
				
				# it "should display the description" do
					# get :show, :id => @reward
					# response.should have_selector("p", :content => @reward.description)
				# end
				
				# it "should display the point cost" do
					# get :show, :id => @reward
					# response.should have_selector("p", :content => @reward.points.to_s)
				# end
			# end
		# end
		
		# describe "GET 'new'" do
			# it "should be successful" do
				# get :new, :company_id => @company
				# response.should be_success
			# end

			# it "should have right title" do
				# get :new, :company_id => @company
				# response.should have_selector("title", :content => "New")
			# end
		# end
		
		# describe "POST 'create'" do
			# describe "failure" do
				# before(:each) do
					# @attr = { :name => "", :description => "", :image_url => "", :points => "", :company_id => @company.id }
				# end
				
				# describe "because reward does not belong to user's company" do
					# it "should redirect to root path" do
						# other_company = FactoryGirl.create(:company)
						# post :create, :reward => @attr.merge(:company_id => other_company.id)
						# response.should redirect_to @user
					# end
				# end
			
				# it "should not create a reward" do
					# lambda do
						# post :create, :reward => @attr
					# end.should_not change(Reward, :count)
				# end
				
				# it "should take you back to the new reward page" do
					# post :create, :reward => @attr
					# response.should render_template("rewards/reward_form")
				# end
			# end
			
			# describe "success" do
				# before(:each) do
					# @attr = { :name => "Test Name", 
					# :description => "Test Description", 
					# :image_url => "http://www.google.com", 
					# :points => 5000, 
					# :company_id => @company.id }
				# end
				
				# it "should create a reward" do
					# lambda do
						# post :create, :reward => @attr
					# end.should change(Reward, :count).by(1)
				# end
				
				# it "should redirect to the reward page" do
					# post :create, :reward => @attr
					# response.should redirect_to(Reward.last)
				# end
				
				# it "should have a flash message" do
					# post :create, :reward => @attr
					# flash[:success].should =~ /reward created/i
				# end
			# end
		# end
		
		# describe "GET 'edit'" do
			# it "should be successful" do
				# get :edit, :id => @reward
				# response.should be_success
			# end

			# it "should have right title" do
				# get :edit, :id => @reward
				# response.should have_selector("title", :content => "Edit")
			# end
			
			# it "should have the right name" do
				# get :edit, :id => @reward
				# response.should have_selector("input", :value => @reward.name)
			# end
		# end
		
		# describe "PUT 'update'" do
			# describe "Failure" do
				# before(:each) do
					# @attr = { :name => "", :description => "", :image_url => "", :points => "", :company_id => @company.id.to_s }
				# end
				
				# it "should render the edit page" do
					# put :update, :id => @reward, :reward => @attr
					# response.should render_template("rewards/reward_form")
				# end
				
				# it "should have the right title" do
					# put :update, :id => @reward, :reward => @attr
					# response.should have_selector("title", :content => "Edit")
				# end
				
				# it "should have an error message" do
					# put :update, :id => @reward, :reward => @attr
					# response.should have_selector("p", :content => "The were problems with the following fields")
				# end
			# end
			
			# describe "Success" do
				# before(:each) do
					# @attr = { :name => "Changed Test Name", 
						# :description => "Changed Test Description", 
						# :image_url => "Changed http://www.google.com", 
						# :points => 100, 
						# :company_id => @company.id }
				# end
				
				# it "Should change the reward successfully" do
					# put :update, :id => @reward, :reward => @attr
					# @reward.reload
					# @reward.name.should == @attr[:name]
					# @reward.description.should == @attr[:description]
					# @reward.points.should == @attr[:points]
				# end
				
				# it "Should redirect to reward page" do
					# put :update, :id => @reward, :reward => @attr
					# response.should redirect_to(reward_path(assigns(:reward)))
				# end
				
				# it "Should have a success message" do
					# put :update, :id => @reward, :reward => @attr
					# flash[:success].should =~ /updated/i
				# end
			# end
		# end
		
		# describe "GET 'review'" do
			# it "should be successful" do
				# get :review, :id => @reward
				# response.should be_success
			# end

			# it "should have right title" do
				# get :review, :id => @reward
				# response.should have_selector("title", :content => "Confirm purchase")
			# end
			
			# it "should have the right name" do
				# get :review, :id => @reward
				# response.should have_selector("h2", :content => @reward.name)
			# end
		# end
		
		# describe "GET 'purchase'" do
			# describe "when user has insufficient points" do
				# before(:each) do
					# @user.earned_points = 10
					# @user.spent_points = 10
					# @user.save!
				# end
				
				# it "should display error message" do
					# get :purchase, :id => @reward
					# flash[:info].should =~ /do not have enough points/i
				# end
				
				# it "should redirect back to review page" do
					# get :purchase, :id => @reward
					# response.should redirect_to review_reward_path(@reward)
				# end
				
				# it "should not create a point transaction" do
					# lambda do
						# get :purchase, :id => @reward
					# end.should_not change(UserTransaction, :count)
				# end
			# end
			
			# describe "when user has sufficient points" do
				# before(:each) do
					# @user.earned_points = @reward_points + 10
					# @user.spent_points = 10
					# @user.save!
				# end
				
				# it "should display success message" do
					# get :purchase, :id => @reward
					# flash[:success].should =~ /purchase successful/i
				# end

				# it "should have right title" do
					# get :purchase, :id => @reward
					# response.should have_selector("title", :content => "Purchase successful")
				# end
				
				# it "should have the right reward name" do
					# get :purchase, :id => @reward
					# response.should have_selector("h2", :content => @reward.name)
				# end
				
				# it "should create a new point transaction" do
					# lambda do
						# get :purchase, :id => @reward
					# end.should change(UserTransaction, :count).by(1)
				# end
				
				# it "should have point transaction with correct reward and points" do
					# get :purchase, :id => @reward
					# pt = UserTransaction.find(:first, :conditions => ["reward_id = ? and user_id = ?", @reward.id, @user.id])
					# pt.reward_id.should == @reward.id
					# pt.amount.should == @reward.points
				# end
			# end
		# end
		
		# describe "DELETE 'destroy'" do
			# it "should destroy the reward" do
				# lambda do
					# delete :destroy, :id => @reward
				# end.should change(Reward, :count).by(-1)
			# end
			
			# it "should redirect to the reward index" do
				# delete :destroy, :id => @reward
				# response.should redirect_to rewards_path(:company_id => @company.id)
			# end
			
			# it "should have a success message" do
				# delete :destroy, :id => @reward
				# flash[:success].should =~ /deleted successfully/i
			# end
		# end
	# end
# end