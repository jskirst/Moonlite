require 'spec_helper'

describe PathsController do
	render_views
	
	describe "access controller" do
		it "should deny access to 'new'" do
			get :new
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
		
		it "should deny access to 'continue'" do
			get :continue, :id => 1
			response.should redirect_to(signin_path)
		end
		
		it "should deny access to 'file'" do
			get :file, :id => 1
			response.should redirect_to(signin_path)
		end
		
		it "should deny access to 'upload'" do
			post :upload, :id => 1
			response.should redirect_to(signin_path)
		end
	end
	
	describe "GET 'new'" do
		before(:each) do
			@user = Factory(:user)
			test_sign_in(@user)
		end
		
		it "should be successful" do
			get :new
			response.should be_success
		end

		it "should have right title" do
			get :new
			response.should have_selector("title", :content => "New Path")
		end
	end
	
	describe "POST 'create'" do
		before(:each) do
			@user = Factory(:user)
			test_sign_in(@user)
		end
		
		describe "failure" do
			before(:each) do
				@attr = { :name => "", :description => "" }
			end
		
			it "should not create a path" do
				lambda do
					post :create, :path => @attr  
				end.should_not change(Path, :count)
			end
			
			it "should send you back to the new page" do
				post :create, :path => @attr
				response.should render_template("paths/new")
			end
		end
		
		describe "success" do
			before(:each) do
				@attr =@attr = { :name => "Test path", :description => "This is a test." }
			end
			
			it "should create a path" do
				lambda do
					post :create, :path => @attr
				end.should change(Path, :count).by(1)		
			end
			
			it "should redirect to the home page" do
				post :create, :path => @attr
				response.should redirect_to(root_path)
			end
			
			it "should have a flash message" do
				post :create, :path => @attr
				flash[:success].should =~ /path created/i
			end
		end
	end
	
	describe "DELETE 'destroy'" do
		describe "as an unauthorized user" do
			before(:each) do
				@user = Factory(:user)
				@path = Factory(:path, :user => @user)
				
				@other_user = Factory(:user, :email => "other@o.com")
				test_sign_in(@other_user)
			end
			
			it "should deny access" do
				delete :destroy, :id => @path
				response.should redirect_to(root_path)
			end
		end
		
		describe "as an authorized user" do
			before(:each) do
				@user = test_sign_in(Factory(:user))
				@path = Factory(:path, :user => @user)
			end
			
			it "should destroy the path" do
				lambda do
					delete :destroy, :id => @path
				end.should change(Path, :count).by(-1)
			end
		end
	end
	
	describe "Get 'show'" do
		before(:each) do
			@user = Factory(:user)
			@path = Factory(:path, :user => @user)
			test_sign_in(@user)
		end
		
		it "should be successful" do
			get :show, :id => @path
			response.should be_success
		end
		
		it "should find the right path" do
			get :show, :id => @path
			assigns(:path).should == @path
		end
		
		it "should have the path's name in the title" do
			get :show, :id => @path
			response.should have_selector("title", :content => @path.name)
		end
		
		it "should have the path's name in the header" do
			get :show, :id => @path
			response.should have_selector("h1", :content => @path.name)
		end
		
		it "should have the path's description" do
			get :show, :id => @path
			response.should have_selector("p", :content => @path.description)
		end
		
		it "should show the users correct points" 
		# do
			# t1 = Factory(:task, :path => @path, :question => "Q1", :answer => "A1", :points => 1)
			# t2 = Factory(:task, :path => @path, :question => "Q2", :answer => "A2", :points => 2)
			# t2 = Factory(:task, :path => @path, :question => "Q3", :answer => "A3", :points => 3)
		# end
		
		it "should have a link to show the paths tasks"
			# t1 = Factory(:task, :path => @path, :question => "Question1", :answer => "Ehhh.", :points => 1)
			# t2 = Factory(:task, :path => @path, :question => "Question2", :answer => "Ehhh.", :points => 1)
			# get :show, :id => @path
			# response.should have_selector("span", :content => t1.question)
			# response.should have_selector("span", :content => t1.answer)
			# response.should have_selector("span", :content => t2.question)
			# response.should have_selector("span", :content => t2.answer)
		# end
	end

	describe "GET 'continue'" do
		before(:each) do
			@creator = Factory(:user)
			@path = Factory(:path, :user => @creator)
			@task1 = Factory(:task, :path => @path, :points => 1, :question => "Q1")
			@task2 = Factory(:task, :path => @path, :points => 2, :question => "Q2")
			@task3 = Factory(:task, :path => @path, :points => 3, :question => "Q3")
			
			@user = Factory(:user, :email => "user@user.com")
			test_sign_in(@user)
			@user.enroll!(@path)
		end
		
		it "should be successful" do
			get :continue, :id => @path
			response.should be_success
		end
		
		it "should find the right path" do
			get :continue, :id => @path
			assigns(:path).should == @path
		end
		
		it "should have the path's name in the title" do
			get :continue, :id => @path
			response.should have_selector("title", :content => @path.name)
		end
		
		it "should display the lowest pointsed task when no tasks are completed" do
			get :continue, :id => @path
			response.should have_selector("p", :content => @task1.question)
		end
		
		it "should display the lowest pointsed task that is not yet completed" do
			@completed_task = Factory(:completed_task, :task => @task1, :user => @user)
			get :continue, :id => @path
			response.should have_selector("p", :content => @task2.question)
		end
		
		it "should render results when the max questions are reached." do
			@completed_task1 = Factory(:completed_task, :task => @task1, :user => @user)
			@completed_task2 = Factory(:completed_task, :task => @task2, :user => @user)
			get :continue, :id => @path, :count => 2, :max => 2
			response.should render_template("results")
			response.should have_selector("title", :content => "Results")
		end
		
		describe "users score on results screen" do
			before(:each) do
				@quiz_session = DateTime.now
			end
		
			it "should be 0/0 when all questions are skipped" do
				@completed_task1 = Factory(:completed_task, :task => @task1, :user => @user, :quiz_session => @quiz_session, :status_id => 2)
				@completed_task2 = Factory(:completed_task, :task => @task2, :user => @user, :quiz_session => @quiz_session, :status_id => 2)
				get :continue, :id => @path, :count => 2, :max => 2
				response.should have_selector("p", :content => "0/0")			
			end
		
			it "should be 0/2 when all answers are incorrect" do
				@completed_task1 = Factory(:completed_task, :task => @task1, :user => @user, :quiz_session => @quiz_session, :status_id => 0)
				@completed_task2 = Factory(:completed_task, :task => @task2, :user => @user, :quiz_session => @quiz_session, :status_id => 0)
				get :continue, :id => @path, :count => 2, :max => 2
				response.should have_selector("p", :content => "0/2")
			end
			
			it "should be 2/2 when all answers are correct" do
				@completed_task1 = Factory(:completed_task, :task => @task1, :user => @user, :quiz_session => @quiz_session, :status_id => 1)
				@completed_task2 = Factory(:completed_task, :task => @task2, :user => @user, :quiz_session => @quiz_session, :status_id => 1)
				get :continue, :id => @path, :count => 2, :max => 2
				response.should have_selector("p", :content => "2/2")
			end
			
			it "should be 1/2 when half answers are incorrect" do
				@completed_task1 = Factory(:completed_task, :task => @task1, :user => @user, :quiz_session => @quiz_session, :status_id => 0)
				@completed_task2 = Factory(:completed_task, :task => @task2, :user => @user, :quiz_session => @quiz_session, :status_id => 1)
				get :continue, :id => @path, :count => 2, :max => 2
				response.should have_selector("p", :content => "1/2")			
			end
		end
	end

	describe "GET 'file'" do
		before(:each) do
			@user = Factory(:user)
			@path = Factory(:path, :user => @user)
			@other_user = Factory(:user, :email => "other@t.com")
		end
		
		describe "as non-creator user" do
			it "should redirect to path" do
				test_sign_in(@other_user)
				get :file, :id => @path
				response.should redirect_to root_path
			end
		end
		
		describe "as creator user" do
			it "should be successful" do
				test_sign_in(@user)
				get :file, :id => @path
				response.should be_success
			end
			
			it "should have right title" do
				test_sign_in(@user)
				get :file, :id => @path
				response.should have_selector("title", :content => "File")
			end
		end
	end
	
	describe "POST 'upload'" do
		before(:each) do
			@user = Factory(:user)
			@path = Factory(:path, :user => @user)
			test_sign_in(@user)
		end
		
		describe "failure" do
			before(:each) do
				@attr = { :file => "asdf" }
			end
		
			it "should not add questions to a path" do
				lambda do
					post :upload, :id => @path.id, :path => @attr
				end.should change(Task, :count).by(0)	
			end
			
			it "should render the file page" do
				post :upload, :id => @path.id, :path => @attr
				response.should render_template("file")
			end
		end
		
		describe "success" do
			before(:each) do
			end
		
			it "should add all questions to a path" 
			
			it "should send you back to the path page"
		end
	end
	
end
	