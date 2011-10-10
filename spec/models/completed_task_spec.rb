require 'spec_helper'

describe CompletedTask do
  	before(:each) do
		@user = Factory(:user)
		@path = Factory(:path, :user => @user)
		@task = Factory(:task, :path => @path)
		@attr = { :task_id => @task.id }
		
		@completed_task = @user.completed_tasks.build(@attr)
	end
	
	it "should create a new instance given valid attributes" do
		@completed_task.save!
	end
	
	describe "complete methods" do
		before(:each) do
			@completed_task.save
		end
		
		it "should have a path user attribute" do
			@completed_task.should respond_to(:user)
		end
		
		it "should have the right user" do
			@completed_task.user_id.should == @user.id
			@completed_task.user.should == @user
		end
		
		it "should respond to path attribute" do
			@completed_task.should respond_to(:task)
		end
		
		it "should have the right path" do
			@completed_task.task_id.should == @task.id
			@completed_task.task.should == @task
		end
	end
	
	describe "validations" do
		it "should require a user_id" do
			@completed_task.user_id = nil
			@completed_task.should_not be_valid
		end
		
		it "should require a task_id" do
			@completed_task.task_id = nil
			@completed_task.should_not be_valid
		end
		
		it "should reject a duplicate completed_task" do
			en1 = Factory(:completed_task, :user => @user, :task => @task)
			en2 = CompletedTask.new
			en2.task_id = @task.id
			en2.user_id = @user.id
			en2.should_not be_valid
		end
	end
end
