require 'spec_helper'
#TODO : Stop creation if user not enrolled

describe CompletedTask do
  	before(:each) do
		@user = Factory(:user)
    @path = Factory(:path, :user => @user, :company => @user.company)
		@section = Factory(:section, :path => @path)
		@task = Factory(:task, :section => @section)
    @user.enroll!(@path)
		@quiz_session = DateTime.now
		@attr = { :task_id => @task.id, :status_id => 0, :quiz_session => @quiz_session }
		@completed_task = @user.completed_tasks.build(@attr)
	end
	
	it "should create a new instance given valid attributes" do
		@completed_task.save!
		@completed_task.reload
		@completed_task.task_id.should == @task.id
		@completed_task.user_id.should == @user.id
		@completed_task.status_id.should == 0
		@completed_task.quiz_session.should == Time.parse(@quiz_session.utc.to_s)
	end
	
	describe "validations" do
		it "should require a user_id" do
			@completed_task.user_id = nil
			@completed_task.should_not be_valid
		end
    
    it "should have a user attribute" do
			@completed_task.should respond_to(:user)
		end
		
		it "should have the right user" do
			@completed_task.user_id.should == @user.id
			@completed_task.user.should == @user
		end
    
    it "should require a task_id" do
			@completed_task.task_id = nil
			@completed_task.should_not be_valid
		end
		
		it "should respond to task attribute" do
			@completed_task.should respond_to(:task)
		end
		
		it "should have the right task" do
			@completed_task.task_id.should == @task.id
			@completed_task.task.should == @task
		end
    
    it "should require a status_id" do
			@completed_task.status_id = nil
			@completed_task.should_not be_valid
		end
		
		it "should have a status_id attribute" do
			@completed_task.should respond_to(:status_id)
		end
    
    it "should require a quiz_session" do
			@completed_task.quiz_session = nil
			@completed_task.should_not be_valid
		end
		
		it "should have a quiz_session attribute" do
			@completed_task.should respond_to(:quiz_session)
		end
    
    it "should reject a task if the user is not enrolled in the tasks path" do
      @user.unenroll!(@path)
      @completed_task.should_not be_valid
    end
	end
end
