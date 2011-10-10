require 'spec_helper'

describe "Tasks" do
	before(:each) do
		@user = Factory(:user)
		@path = Factory(:path, :user => @user)
		@attr = { :question => "This is a question",
			:answer => "This is an answer.",
			:resource => "http://www.wikipedia.com",
			:rank => 1 }
	end
	
	it "should create a new instance given valid attributes" do
		@path.tasks.create!(@attr)
	end
	
	describe "path associations" do
		before(:each) do
			@task = @path.tasks.create(@attr)
		end
		
		it "should have a path attribute" do
			@task.should respond_to(:path)
		end
		
		it "should have the right associated path" do
			@task.path_id.should == @path.id
			@task.path.should == @path
		end
	end
	
	describe "validations" do
	
		it "should require a path id" do
			Task.new(@attr).should_not be_valid
		end
		
		it "should require non-blank question, rank and answer" do
			@user.paths.build(:question => "", :answer => "", :rank => nil).should_not be_valid
		end
		
		it "should reject long questions and answers" do
			@user.paths.build(:question => "a"*256, :answer => "a"*256, :rank => 1).should_not be_valid
		end
		
		it "should a reject rank thats too high" do
			@user.paths.build(:question => @attr[:question], :answer => @attr[:answer], :rank => 51).should_not be_valid
		end
	end
end
