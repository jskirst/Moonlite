require 'spec_helper'

describe CompletedTasksController do
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
			@path = Factory(:path, :user => @user)
			@task = Factory(:task, :path => @path)
			@user.enroll!(@path)			
			test_sign_in(@user)
		end
		
		describe "failure" do
			before(:each) do
				@attr = { :user_id => "", :task_id => "", :answer => "" }
			end
		
			it "should not create an completed task" do
				lambda do
					post :create, :completed_task => @attr  
				end.should_not change(CompletedTask, :count)
			end
			
			it "should take you back to the root path" do
				post :create, :completed_task => @attr
				response.should redirect_to root_path
			end
		end
		
		describe "success" do
			before(:each) do
				@attr = { :user_id => @user.id, :task_id => @task.id, :answer => @task.answer }
			end
			
			it "should create a completed task" do
				lambda do
					post :create, :completed_task => @attr
				end.should change(CompletedTask, :count).by(1)		
			end
			
			it "should go back to the continue path page" do
				post :create, :completed_task => @attr
				response.should redirect_to continue_path_path :id => @path
			end
			
			it "should have a flash message" do
				post :create, :completed_task => @attr
				flash[:success].should =~ /correct/i
			end
		end
	end
	
	describe "DELETE 'destroy'" do
		before(:each) do
			@user = Factory(:user)
			@path = Factory(:path, :user => @user)
			@task = Factory(:task, :path => @path)
			@user.enroll!(@path)			
			@completed_task = Factory(:completed_task, :user => @user, :task => @task)
		end
		
		describe "as an unauthorized user" do
			before(:each) do
				@other_user = Factory(:user, :email => "o@o.com")
				test_sign_in(@other_user)
			end
			
			it "should deny access" do
				delete :destroy, :id => @completed_task
				response.should redirect_to(root_path)
			end
		end
		
		describe "as an authorized user" do
			before(:each) do
				test_sign_in(@user)
			end
			
			it "should destroy the completed task" do
				lambda do
					delete :destroy, :id => @completed_task
				end.should change(CompletedTask, :count).by(-1)
			end
		end
	end
end
	