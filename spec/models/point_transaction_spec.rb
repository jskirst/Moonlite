require 'spec_helper'

describe PointTransaction do
	before(:each) do
		@user = Factory(:user)
		@company = Factory(:company)
		@company_user = Factory(:company_user, :user => @user, :company => @company)
		
		@path = Factory(:path, :user => @user)
		@task = Factory(:task, :path => @path)
		
		@attr = { :user_id => @user, :points => @task.points }
		@task_transaction_attr = @attr.merge(:task_id => @task, :status => 1)
	end
	
	it "should create a new instance given valid attributes for tasks" do
		PointTransaction.create!(@task_transaction_attr)
	end
	
	# it "should create a new instance given valid attributes for rewards" do
		# @company_user.save!
	# end
	
	describe "attributes" do
		before(:each) do
			@task_point_transaction = PointTransaction.create!(@task_transaction_attr)
		end
		
		it "should respond to user" do
			@task_point_transaction.should respond_to(:user)
		end
		
		it "should respond with the right user" do
			@task_point_transaction.user_id.should == @user.id
			@task_point_transaction.user.should == @user
		end
		
		it "should respond to task" do
			@task_point_transaction.should respond_to(:task)
		end
		
		it "should respond with the right task" do
			@task_point_transaction.task_id.should == @task.id
			@task_point_transaction.task.should == @task
		end
		
		it "should have a points attribute" do
			@task_point_transaction.should respond_to(:points)
		end
		
		it "should have a status attribute" do
			@task_point_transaction.should respond_to(:status)
		end
	end
end
