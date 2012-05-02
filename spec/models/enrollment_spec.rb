require 'spec_helper'

describe Enrollment do
	before(:each) do
		@user = FactoryGirl.create(:user)
		@path = FactoryGirl.create(:path, :user => @user, :company => @user.company)
		@attr = { :path_id => @path.id }
		@enrollment = @user.enrollments.build(@attr)
	end
	
	it "should create a new instance given valid attributes" do
		@enrollment.save!
	end
	
	describe "validations" do
		it "should require a user_id" do
			@enrollment.user_id = nil
			@enrollment.should_not be_valid
		end
    
    it "should have a user attribute" do
			@enrollment.should respond_to(:user)
		end
		
		it "should have the right user" do
			@enrollment.user_id.should == @user.id
			@enrollment.user.should == @user
		end
    
    it "should require a path_id" do
			@enrollment.path_id = nil
			@enrollment.should_not be_valid
		end
		
		it "should respond to path attribute" do
			@enrollment.should respond_to(:path)
		end
		
		it "should have the right path" do
			@enrollment.path_id.should == @path.id
			@enrollment.path.should == @path
		end
    
    it "should reject a path not owned by the company" do
      @other_user = FactoryGirl.create(:user)
      @other_path = FactoryGirl.create(:path, :user => @other_user, :company => @other_user.company)
      @enrollment.path_id = @other_path.id
      @enrollment.should_not be_valid
    end
		
		it "should reject a duplicate enrollment" do
			en1 = FactoryGirl.create(:enrollment, :user => @user, :path => @path)
			en2 = Enrollment.new
			en2.path_id = @path.id
			en2.user_id = @user.id
			en2.should_not be_valid
		end
	end
end
