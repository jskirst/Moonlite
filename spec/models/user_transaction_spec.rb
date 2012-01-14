require 'spec_helper'

describe UserTransaction do
	before(:each) do
		@user = Factory(:user)
		@company = Factory(:company)
		@company_user = Factory(:company_user, :user => @user, :company => @company)
		@attr = { :user_id => @user, :amount => 15, :status => 1 }
	end
	
	describe "validation" do
		it "should require at least one of the following - path_id, reward_id, task_id" do
			UserTransaction.new(@attr).should_not be_valid
		end
		
		describe "for tasks" do
			before(:each) do
				@path = Factory(:path, :user => @user)
				@task = Factory(:task, :path => @path)
				@attr = @attr.merge(:task_id => @task)
				@transaction = UserTransaction.create!(@attr)
			end
		
			it "should respond to task" do
				@transaction.should respond_to(:task)
			end
		
			it "should respond with the right task" do
				@transaction.task_id.should == @task.id
				@transaction.task.should == @task
			end
			
			it "should respond to user" do
				@transaction.should respond_to(:user)
			end
		
			it "should respond with the right user" do
				@transaction.user_id.should == @user.id
				@transaction.user.should == @user
			end
			
			it "should respond to amount" do
				@transaction.should respond_to(:amount)
			end
			
			it "should require an amount value" do
				UserTransaction.new(@attr.delete("amount")).should_not be_valid
			end
			
			it "should have a status attribute" do
				@transaction.should respond_to(:status)
			end
		end
		
		describe "for rewards" do
			before(:each) do
				@reward = Factory(:reward, :company => @company)
				@attr = @attr.merge(:reward_id => @reward)
				@transaction = UserTransaction.create!(@attr)
			end
			
			it "should create a new instance given valid attributes for rewards" do
				UserTransaction.create!(@attr)
			end
		
			it "should respond to reward" do
				@transaction.should respond_to(:reward)
			end
		
			it "should respond with the right reward" do
				@transaction.reward_id.should == @reward.id
				@transaction.reward.should == @reward
			end
		end
		
		describe "for paths" do
			before(:each) do
				@path = Factory(:path, :user => @user)
				@attr = @attr.merge(:path_id => @path)
				@transaction = UserTransaction.create!(@attr)
			end
		
			it "should respond to path" do
				@transaction.should respond_to(:path)
			end
		
			it "should respond with the right path" do
				@transaction.path_id.should == @path.id
				@transaction.path.should == @path
			end
		end
	end
end
