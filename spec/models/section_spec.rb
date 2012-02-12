require 'spec_helper'

describe "Section" do
	before(:each) do
		@user = Factory(:user)
		@path = Factory(:path, :user => @user)
		@attr = { :name => "In the beginning", :instructions => "DO THINGSSSS!!!!", :position => 0 }
	end
	
	it "should create a new instance given valid attributes" do
		@path.sections.create!(@attr)
	end
	
	describe "attributes" do
		before(:each) do
			@section = @path.sections.create(@attr)
		end
		
		it "should include a name" do
			@section.should respond_to(:name)
		end		
		
		it "should include instructions" do
			@section.should respond_to(:instructions)
		end
		
		it "should include position" do
			@section.should respond_to(:position)
		end
    
    it "should have position begin at 1" do
      @section.position.should == 1
    end
    
    it "should have increment the position value by 1" do
      s2 = @path.sections.create(@attr)
      s2.position.should == 2
    end
	end
	
	describe "path associations" do
		before(:each) do
			@section = @path.sections.create(@attr)
		end
		
		it "should have a path attribute" do
			@section.should respond_to(:path)
		end
		
		it "should have the right associated path" do
			@section.path_id.should == @path.id
			@section.path.should == @path
		end
	end
	
	describe "validations" do
		it "should require a path id" do
			Section.new(@attr).should_not be_valid
		end
		
		it "should require non-blank name" do
			@path.sections.build(@attr.merge(:name => "")).should_not be_valid
		end
		
		it "should require non-blank instructions" do
			@path.sections.build(@attr.merge(:instructions => "")).should_not be_valid
		end
		
		it "should reject long names" do
			@path.sections.build(@attr.merge(:name => "a"*256)).should_not be_valid
		end
		
		it "should reject long instructions" do
			@path.sections.build(@attr.merge(:instructions => "a"*3000)).should_not be_valid
		end
  end
	
	describe "task associations" do
		before(:each) do
			@section = Factory(:section)
			@task1 = Factory(:task, :section => @section)
			@task2 = Factory(:task, :section => @section)
      @section.reload
		end
		
		it "should have a paths attribute" do
			@section.should respond_to(:tasks)
		end
		
		it "should have the right paths in the right order (lowest position first)" do
			@section.tasks.should == [@task1, @task2]
		end
		
		it "should destroy associated tasks" do
			@section.destroy
			[@task1, @task2].each do |t|
				Task.find_by_id(t.id).should be_nil
			end
		end
		
		describe "next task" do
			before(:each) do
				@completed_task = Factory(:completed_task, :user => @user, :task => @task1)
			end
		
			it "should have a next task method" do
				@section.should respond_to(:next_task)
			end
			
			it "should return the next uncompleted task for a user" do
				@section.next_task(@user).should == @task2
			end
			
			it "should return nil if there are no more incomplete tasks" do
				@completed_task2 = Factory(:completed_task, :user => @user, :task => @task2)
				@section.next_task(@user).should == nil
			end
		end		
		
		describe "remaining tasks" do
			before(:each) do
				@completed_task = Factory(:completed_task, :user => @user, :task => @task1)
			end
		
			it "should have a next task method" do
				@section.should respond_to(:remaining_tasks)
			end
			
			it "should return the next the correct number of incomplete tasks"
			# do
				# @section.remaining_tasks(@user).should == @path.tasks.count - @user.completed_tasks.count
			# end
		end
	end
end
