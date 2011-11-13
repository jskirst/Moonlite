require 'spec_helper'

describe "Paths" do
	before(:each) do
		@user = Factory(:user)
		@attr = { :name => "Test name", :description => "Test description", :created_at => 1.day.ago }
	end
	
	it "should create a new instance given valid attributes" do
		@user.paths.create!(@attr)
	end
	
	describe "user associations" do
		before(:each) do
			@path = @user.paths.create(@attr)
		end
		
		it "should have a user attribute" do
			@path.should respond_to(:user)
		end
		
		it "should have the right associated user" do
			@path.user_id.should == @user.id
			@path.user.should == @user
		end
	end
	
	describe "validations" do
		it "should require a user id" do
			Path.new(@attr).should_not be_valid
		end
		
		it "should require non-blank content" do
			@user.paths.build(:content => "").should_not be_valid
		end
		
		it "should reject long content" do
			@user.paths.build(:content => "a"*141).should_not be_valid
		end
	end
	
	describe "tasks" do
		before(:each) do
			@path = Factory(:path, :user => @user)
			@task1 = Factory(:task, :path => @path, :points => 1)
			@task2 = Factory(:task, :path => @path, :points => 2)
		end
		
		it "should have a paths attribute" do
			@path.should respond_to(:tasks)
		end
		
		it "should have the right paths in the right order (lowest points first)" do
			@path.tasks.should == [@task1, @task2]
		end
		
		it "should destroy associated tasks" do
			@path.destroy
			[@task1, @task2].each do |t|
				Task.find_by_id(t.id).should be_nil
			end
		end
		
		describe "next task" do
			before(:each) do
				@completed_task = Factory(:completed_task, :user => @user, :task => @task1)
			end
		
			it "should have a next task method" do
				@path.should respond_to(:next_task)
			end
			
			it "should return the next uncompleted task for a user" do
				@path.next_task(@user).should == @task2
			end
			
			it "should return nil if there are no more incomplete tasks" do
				@completed_task2 = Factory(:completed_task, :user => @user, :task => @task2)
				@path.next_task(@user).should == nil
			end
		end		
		
		describe "remaining tasks" do
			before(:each) do
				@completed_task = Factory(:completed_task, :user => @user, :task => @task1)
			end
		
			it "should have a next task method" do
				@path.should respond_to(:remaining_tasks)
			end
			
			it "should return the next the correct number of incomplete tasks" do
				@path.remaining_tasks(@user).should == @path.tasks.count - @user.completed_tasks.count
			end
		end
	end
end
