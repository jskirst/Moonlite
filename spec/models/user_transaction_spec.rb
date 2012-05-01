require 'spec_helper'

describe UserTransaction do
	before(:each) do
		@company = Factory(:company)
		@user_roll = Factory(:user_roll, :company => @company)
		@user = Factory(:user, :company => @company, :user_roll => @user_roll)
		
		@category = Factory(:category, :company => @company)
		@path = Factory(:path, :user => @user, :category => @category, :company => @user.company)
		@section = Factory(:section, :path => @path)
		@task = Factory(:task, :section => @section)
		
		@reward = Factory(:reward, :company => @user.company)
    @user.enroll!(@path)
		@attr = { :user_id => @user.id, :amount => 15, :status => 1 }
	end
	
	describe "validation" do
		it "should require at least one of the following - path_id, reward_id, task_id" do
			UserTransaction.new(@attr).should_not be_valid
		end
		
		it "should reject transaction with path and task" do
			UserTransaction.new(@attr.merge(:path_id => @path, :task_id => @task)).should_not be_valid
		end
		
		it "should reject transaction with path and reward" do
			UserTransaction.new(@attr.merge(:path_id => @path, :reward_id => @reward)).should_not be_valid
		end
		
		it "should reject transaction with reward and task" do
			UserTransaction.new(@attr.merge(:reward_id => @reward, :task_id => @task)).should_not be_valid
		end
		
		describe "for tasks" do
			before(:each) do
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
      
      it "should reject a task that the user is not enrolled in" 
      # do
				# @other_user = Factory(:user, :company => @user.company)
        # transaction = UserTransaction.create(@attr.merge(:user_id => @other_user.id))
        # transaction.should_not be_valid
			# end
		end
		
		describe "for rewards" do
			before(:each) do
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
				@attr = { :user_id => @user.id, :amount => 15, :status => 1, :path_id => @path.id }
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
