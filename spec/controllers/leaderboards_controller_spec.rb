require 'spec_helper'

describe LeaderboardsController do
  render_views
  
  before(:each) do
    @company = Factory(:company)
		@user1 = Factory(:user, :company => @company)
		@user2 = Factory(:user, :company => @company)
		@user3 = Factory(:user, :company => @company)
    @users = [@user1, @user2, @user3]
    
		@password = "alltheaboveplease"
	end
  
  describe "access controller" do
		describe "when not signed in" do
			it "should deny access to 'new'" do
				get :new
				response.should redirect_to(signin_path)
			end
		
			it "should deny access to 'create'" do
				post :create, :leaderboard => @attr
				response.should redirect_to(signin_path)
			end	
      
      it "should deny access to 'index'" do
				get :index
				response.should redirect_to(signin_path)
			end
		end
		
		describe "when signed in as a regular user" do
			before(:each) do
				test_sign_in(@user1)
			end
			
			it "should deny access to 'new'" do
				get :new
				response.should redirect_to root_path
			end
		
			it "should deny access to 'create'" do
				post :create, :achievement => @attr
				response.should redirect_to root_path
			end
      
      it "should deny access to 'index'" do
				get :index
				response.should be_success
			end
		end
		
		describe "when signed in as admin" do
			before(:each) do
				@user1.toggle!(:admin)
				test_sign_in(@user1)
			end
			
			it "should allow access to 'new'" do
				get :new
				response.should be_success
			end
		
			it "should allow access to 'create'" do
				post :create, :password => @password
        response.should be_success
			end
      
      it "should allow access to 'index'" do
				get :index
				response.should be_success
			end
		end
	end
  
  describe "actions" do
    before(:each) do
      @user1.toggle!(:admin)
      test_sign_in(@user1)
      
      @path = Factory(:path, :company => @company, :user => @user1)
      @section = Factory(:section, :path => @path)
      @task1 = Factory(:task, :section => @section)
      @task2 = Factory(:task, :section => @section)
      @task3 = Factory(:task, :section => @section)
      
      @user1.enroll!(@path)
      Factory(:completed_task, :task => @task1, :user => @user1)
      Factory(:completed_task, :task => @task2, :user => @user1)
      Factory(:completed_task, :task => @task3, :user => @user1)
      @user1.award_points(@task1)
      @user1.award_points(@task2)
      @user1.award_points(@task3)
      
      @user2.enroll!(@path)
      Factory(:completed_task, :task => @task1, :user => @user2)
      Factory(:completed_task, :task => @task2, :user => @user2)
      @user2.award_points(@task1)
      @user2.award_points(@task2)
    end
    
    describe "GET index" do
      before(:each) do
        post :create, :password => @password
      end
      
      it "should be a success" do
				get :index
				response.should be_success
			end
      
      it "should correctly list the name of each user" 
      # do
				# get :index
        # @users.each do |u|
          # response.should have_selector("tr .user-name", :content => u.name)
        # end
			# end
      
      it "should correctly list the number of completed task for each user" do
				get :index
        response.should have_selector("tr .user-completed-tasks", :content => "3")
        response.should have_selector("tr .user-completed-tasks", :content => "2")
        response.should have_selector("tr .user-completed-tasks", :content => "0")
			end
      
      it "should correctly list the number of completed task for each user" do
				get :index
        response.should have_selector("tr .user-score", :content => "15")
        response.should have_selector("tr .user-score", :content => "10")
        response.should have_selector("tr .user-score", :content => "0")
			end
    end

    describe "GET new" do
      it "should be a success" do
				get :index
				response.should be_success
			end
    end

    describe "POST create" do
      describe "with valid params" do
        it "creates a new set of Leaderboards" do
          lambda do
            post :create, :password => @password
          end.should change(Leaderboard, :count).by(3)
        end
      end

      describe "with invalid params" do
        it "should not create a new set of Leaderboards" do
          lambda do
            post :create, :leaderboard => {:password => "wrongpassword"}
          end.should_not change(Leaderboard, :count)
        end
        
        it "should be a render new" do
          post :create, :leaderboard => @attr
          response.should render_template "new"
        end
      end
    end
  end
end
