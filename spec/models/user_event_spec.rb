require 'spec_helper'

describe "UserEvent" do
	before(:each) do
		@company = Factory(:company)
		@default_roll = Factory(:user_roll, :company => @company)
		@user = Factory(:user, :company => @company, :user_roll => @default_roll)
		
		@category = Factory(:category, :company => @company)
		@path = Factory(:path, :company => @company, :user => @user, :category => @category)
		
		@attr = { :content => "Content is wack", :path_id => @path.id }
	end
	
	it "should create a new instance given valid attributes" do
		@user.enroll!(@path)
		@user.user_events.create!(@attr)
	end
	
	describe "attributes" do
		before(:each) do
			@user.enroll!(@path)
			@user_event = @user.user_events.create(@attr)
		end	
		
		it "should include a content" do
			@user_event.should respond_to(:content)
		end
		
		it "should include a content" do
			@user.user_events.build(@attr.merge(:content => "")).should_not be_valid
		end
	end
	
	describe "path association" do
		it "should require user be enrolled in path" do
			@user.user_events.build(@attr).should_not be_valid
		end
		
		it "should have a path attribute" do
			@user.enroll!(@path)
			@user_event = @user.user_events.create!(@attr)
			@user_event.should respond_to(:path)
		end
		
		it "should have the right associated company" do
			@user.enroll!(@path)
			@user_event = @user.user_events.create!(@attr)
			@user_event.path_id.should == @path.id
			@user_event.path.should == @path
		end
	end
	
	describe "user association" do
		before(:each) do
			@user.enroll!(@path)
			@user_event = @user.user_events.create!(@attr)
		end
		
		it "should have a company attribute" do
			@user_event.should respond_to(:user)
		end
		
		it "should have the right associated users" do
			@user.enroll!(@path)
			@user_event = @user.user_events.create!(@attr)
			@user_event.user_id.should == @user.id
			@user_event.user.should == @user
		end
	end
end
