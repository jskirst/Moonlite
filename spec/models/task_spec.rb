require 'spec_helper'

describe "Tasks" do
	before(:each) do
		@user = Factory(:user)
		@path = Factory(:path, :user => @user)
		@attr = { :question => "This is a question",
			:answer1 => "This is an answer.",
			:answer2 => nil,
			:answer3 => nil,
			:answer4 => nil,
			:resource => "http://www.wikipedia.com",
			:points => 1 }
	end
	
	it "should create a new instance given valid attributes" do
		@path.tasks.create!(@attr)
	end
	
	describe "attributes" do
		before(:each) do
			@task = @path.tasks.create(@attr)
		end
		
		it "should include a question" do
			@task.should respond_to(:question)
		end		
		
		it "should include a points" do
			@task.should respond_to(:points)
		end
		
		it "should include an answer1" do
			@task.should respond_to(:answer1)
		end		
		
		it "should include an answer2" do
			@task.should respond_to(:answer2)
		end
		
		it "should include an answer3" do
			@task.should respond_to(:answer3)
		end
		
		it "should include an answer4" do
			@task.should respond_to(:answer4)
		end
		
		it "should include a correct_answer" do
			@task.should respond_to(:correct_answer)
		end
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
		
		it "should require non-blank question" do
			@path.tasks.build(@attr.merge(:question => "")).should_not be_valid
		end
		
		it "should require non-blank answer1" do
			@path.tasks.build(@attr.merge(:answer1 => "")).should_not be_valid
		end
		
		it "should require non-nil points" do
			@path.tasks.build(@attr.merge(:points => nil)).should_not be_valid
		end		
		
		it "should require non-nil correct_answer" do
			@path.tasks.build(@attr.merge(:correct_answer => nil)).should_not be_valid
		end
		
		it "should reject long questions" do
			@path.tasks.build(@attr.merge(:question => "a"*256)).should_not be_valid
		end
		
		it "should reject long answers" do
			@path.tasks.build(@attr.merge(:answer1 => "a"*256)).should_not be_valid
		end
		
		it "should a reject points value thats too high" do
			@path.tasks.build(@attr.merge(:points => 51)).should_not be_valid
		end
		
		it "should a reject out of range correct answers" do
			@path.tasks.build(@attr.merge(:correct_answer => 5)).should_not be_valid
		end
	end
end
