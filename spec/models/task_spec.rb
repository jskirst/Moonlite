require 'spec_helper'

describe "Tasks" do
	before(:each) do
		@user = Factory(:user)
		@section = Factory(:section)
		@attr = { :question => "This is a question",
			:answer1 => "This is an answer.",
			:answer2 => "This is an answer2.",
			:answer3 => "This is an answer3.",
			:answer4 => "This is an answer4.",
			:resource => "http://www.wikipedia.com",
			:points => 1 }
	end
	
	it "should create a new instance given valid attributes" do
		@section.tasks.create!(@attr)
	end
	
	describe "attributes" do
		before(:each) do
			@task = @section.tasks.create(@attr)
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
    
    it "should include a position" do
      @task.should respond_to(:position)
    end
    
    it "should have position begin at 1" do
      @task.position.should == 1
    end
    
    it "should have increment the position value by 1" do
      t2 = @section.tasks.create(@attr)
      t2.position.should == 2
    end
	end
	
	describe "section associations" do
		before(:each) do
			@task = @section.tasks.create(@attr)
		end
		
		it "should have a section attribute" do
			@task.should respond_to(:section)
		end
		
		it "should have the right associated section" do
			@task.section_id.should == @section.id
			@task.section.should == @section
		end
	end
	
	describe "validations" do
		it "should require a section id" do
			Task.new(@attr).should_not be_valid
		end
		
		it "should require non-blank question" do
			@section.tasks.build(@attr.merge(:question => "")).should_not be_valid
		end
		
		it "should require non-nil points" do
			@section.tasks.build(@attr.merge(:points => nil)).should_not be_valid
		end		
		
		it "should require non-nil correct_answer" do
			@section.tasks.build(@attr.merge(:correct_answer => nil)).should_not be_valid
		end
		
		it "should reject long questions" do
			@section.tasks.build(@attr.merge(:question => "a"*256)).should_not be_valid
		end
		
		it "should reject long answers" do
			@section.tasks.build(@attr.merge(:answer1 => "a"*256)).should_not be_valid
		end
		
		it "should a reject points value thats too high" do
			@section.tasks.build(@attr.merge(:points => 51)).should_not be_valid
		end
		
		it "should a reject out of range correct answers" do
			@section.tasks.build(@attr.merge(:correct_answer => 5)).should_not be_valid
		end
	end
end