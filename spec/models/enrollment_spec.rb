require 'spec_helper'

describe Enrollment do
	before(:each) do
		@user = Factory(:user)
		@path = Factory(:path, :user => @user)
		@attr = { :path_id => @path.id }
		
		@enrollment = @user.enrollments.build(@attr)
	end
	
	it "should create a new instance given valid attributes" do
		@enrollment.save!
	end
	
	describe "enroll methods" do
		before(:each) do
			@enrollment.save
		end
		
		it "should have a path user attribute" do
			@enrollment.should respond_to(:user)
		end
		
		it "should have the right user" do
			@enrollment.user_id.should == @user.id
			@enrollment.user.should == @user
		end
		
		it "should respond to path attribute" do
			@enrollment.should respond_to(:path)
		end
		
		it "should have the right path" do
			@enrollment.path_id.should == @path.id
			@enrollment.path.should == @path
		end
	end
	
	describe "validations" do
		it "should require a user_id" do
			@enrollment.user_id = nil
			@enrollment.should_not be_valid
		end
		
		it "should require a path_id" do
			@enrollment.path_id = nil
			@enrollment.should_not be_valid
		end
		
		it "should reject a duplicate enrollment" do
			en1 = Factory(:enrollment, :user => @user, :path => @path)
			en2 = Enrollment.new
			en2.path_id = @path.id
			en2.user_id = @user.id
			en2.should_not be_valid
		end
	end
end
