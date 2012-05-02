require 'spec_helper'

describe "Section" do
	before(:each) do
		@user = FactoryGirl.create(:user)
		@path = FactoryGirl.create(:path, :user => @user, :company => @user.company)
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
		
		it "should return the default section pic if image_url not provided" do
			@section.pic.should =~ /default/i
		end
		
		it "should return the default section pic if image_url not provided" do
			@section = @path.sections.create(@attr.merge(:image_url => "hello.jpg"))
			@section.pic.should =~ /hello/i
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
		
		it "should reject long names" do
			@path.sections.build(@attr.merge(:name => "a"*256)).should_not be_valid
		end
  end
	
	describe "task associations" do
		before(:each) do
      @user.enroll!(@path)
			@section = FactoryGirl.create(:section, :path => @path)
			@task1 = FactoryGirl.create(:task, :section => @section, :position => 1)
			@task2 = FactoryGirl.create(:task, :section => @section, :position => 2)
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
		
		describe "next_task" do
			before(:each) do
				FactoryGirl.create(:completed_task, :user => @user, :task => @task1)
        @section.reload
			end
		
			it "should have a next task method" do
				@section.should respond_to(:next_task)
			end
			
			it "should return nil if there are no more incomplete tasks" do
				FactoryGirl.create(:completed_task, :user => @user, :task => @task2)
				@section.next_task(@user).should == nil
			end
		end
		
		describe "randomize_tasks" do
			it "should not randomize if only one task" do
				@task2.destroy
				@old_task_array = @section.tasks_to_array
				@section.randomize_tasks
				@section.tasks_to_array.should == @old_task_array
			end
		
			it "should randomize task order" do
				@task3 = FactoryGirl.create(:task, :section => @section)
				@old_task_array = @section.tasks_to_array
				@section.randomize_tasks
				@section.tasks_to_array.should_not == @old_task_array
			end
		end
		
		describe "completed?" do
			it "should return false if remaining tasks is not 0" do
				FactoryGirl.create(:completed_task, :user => @user, :task => @task1)
				FactoryGirl.create(:completed_task, :user => @user, :task => @task2, :status_id => 0)
				@section.completed?(@user).should be_false
			end			
			
			it "should return false if remaining tasks is not 0" do
				FactoryGirl.create(:completed_task, :user => @user, :task => @task1)
				FactoryGirl.create(:completed_task, :user => @user, :task => @task2)
				@section.completed?(@user).should be_true
			end
			
			it "should return appropriate number of remaining tasks" do
				FactoryGirl.create(:completed_task, :user => @user, :task => @task1)
				FactoryGirl.create(:completed_task, :user => @user, :task => @task2, :status_id => 0)
				@section.remaining_tasks(@user).should == 1
			end	
		end
		
		describe "user_streak" do
			before(:each) do
				@task3 = FactoryGirl.create(:task, :section => @section)
			end
		
			describe "for positive streak" do
				it "should return appropriate user streak" do
					FactoryGirl.create(:completed_task, :user => @user, :task => @task1, :status_id => 0)
					FactoryGirl.create(:completed_task, :user => @user, :task => @task1)
					FactoryGirl.create(:completed_task, :user => @user, :task => @task2)
					FactoryGirl.create(:completed_task, :user => @user, :task => @task3)
					@section.user_streak(@user).should == 3
				end
			end
			
			describe "for negative streak" do
				it "should return appropriate user streak" do
					FactoryGirl.create(:completed_task, :user => @user, :task => @task1)
					FactoryGirl.create(:completed_task, :user => @user, :task => @task2)
					FactoryGirl.create(:completed_task, :user => @user, :task => @task3, :status_id => 0)
					FactoryGirl.create(:completed_task, :user => @user, :task => @task3, :status_id => 0)
					FactoryGirl.create(:completed_task, :user => @user, :task => @task3, :status_id => 0)
					@section.user_streak(@user).should == -3
				end
			end
		end
		
	end
end
