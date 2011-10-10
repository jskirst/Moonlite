require 'spec_helper'

describe TasksController do
	render_views
	
	describe "access controller" do
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
	
	describe "Get 'show'" do
		before(:each) do
			@user = Factory(:user)
			@path = Factory(:path, :user => @user)
			@task = Factory(:task, :path => @path)
			test_sign_in(@user)
		end
		
		it "should be successful" do
			get :show, :id => @task
			response.should be_success
		end
		
		it "Should find the right task" do
			get :show, :id => @task
			assigns(:task).should == @task
		end
		
		it "Should have the path's name in the title" do
			get :show, :id => @task
			response.should have_selector("title", :content => @path.name)
		end
		
		it "should display the question" do
			get :show, :id => @task
			response.should have_selector("p", :content => @task.question)
		end
		
		it "should display the answer" do
			get :show, :id => @task
			response.should have_selector("p", :content => @task.answer)
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
			response.should have_selector("title", :content => "New Task")
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
				@attr = { :question => "",
					:answer => "",
					:resource => "",
					:rank => nil,
					:path_id => @path.id}
			end
		
			it "should not create a task" do
				lambda do
					post :create, :task => @attr  
				end.should_not change(Path, :count)
			end
			
			it "should take you back to the new task page" do
				post :create, :task => @attr
				response.should render_template('tasks/new')
			end
		end
		
		describe "success" do
			before(:each) do
				@attr = { :question => "This is a question",
					:answer => "This is an answer.",
					:resource => "http://www.wikipedia.com",
					:rank => 1,
					:path_id => 1}
			end
			
			it "should create a task" do
				lambda do
					post :create, :task => @attr
				end.should change(Task, :count).by(1)		
			end
			
			it "should redirect to the path page" do
				post :create, :task => @attr
				response.should redirect_to(@path)
			end
			
			it "should have a flash message" do
				post :create, :task => @attr
				flash[:success].should =~ /task created/i
			end
		end
	end
	
	describe "DELETE 'destroy'" do
		describe "as an unauthorized user" do
			before(:each) do
				@user = Factory(:user)
				@path = Factory(:path, :user => @user)
				@task = Factory(:task, :path => @path)
				
				@other_user = Factory(:user, :email => "other@o.com")
				test_sign_in(@other_user)
			end
			
			it "should deny access" do
				delete :destroy, :id => @task
				response.should redirect_to(root_path)
			end
		end
		
		describe "as an authorized user" do
			before(:each) do
				@user = test_sign_in(Factory(:user))
				@path = Factory(:path, :user => @user)
				@task = Factory(:task, :path => @path)
			end
			
			it "should destroy the task" do
				lambda do
					delete :destroy, :id => @task
				end.should change(Task, :count).by(-1)
			end
		end
	end
	
	describe "GET 'edit'" do
		before(:each) do
			@user = Factory(:user)
			@path = Factory(:path, :user => @user)
			@task = Factory(:task, :path => @path)
			test_sign_in @user
		end
		
		it "should be successful" do
			get :edit, :id => @task
			response.should be_success
		end

		it "should have right title" do
			get :edit, :id => @task
			response.should have_selector("title", :content => "Edit")
		end
	end
	
	describe "PUT 'update'" do
		before(:each) do
			@user = Factory(:user)
			@path = Factory(:path, :user => @user)
			@task = Factory(:task, :path => @path)
			test_sign_in(@user)
		end
		
		describe "Failure" do
			before(:each) do
				@attr = {:question => "", 
				:answer => "", 
				:resource => "", 
				:rank => ""}
			end
			
			it "should render the edit page" do
				put :update, :id => @task, :task => @attr
				response.should render_template('edit')
			end
			
			it "should have the right title" do
				put :update, :id => @task, :task => @attr
				response.should have_selector("title", :content => "Edit")
			end
			
			it "should have an error message" do
				put :update, :id => @task, :task => @attr
				response.should have_selector("p", :content => "The were problems with the following fields")
			end
		end
		
		describe "Success" do
			before(:each) do
				@attr = {:question => "Replacement question", 
				:answer => "Replacement answer", 
				:resource => "fake", 
				:rank => 1}
			end
			
			it "Should change task successfully" do
				put :update, :id => @task, :task => @attr
				@task.reload
				@task.question.should == @attr[:question]
				@task.answer.should == @attr[:answer]
				@task.resource.should == @attr[:resource]
				@task.rank.should == @attr[:rank]
			end
			
			it "Should redirect to task page" do
				put :update, :id => @task, :task => @attr
				response.should redirect_to(task_path(assigns(:task)))
			end
			
			it "Should have a success message" do
				put :update, :id => @task, :task => @attr
				flash[:success].should =~ /updated/i
			end
		end
	end
end
	