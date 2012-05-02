require 'spec_helper'

describe Comment do
	before(:each) do
    @user = FactoryGirl.create(:user)
		@path = FactoryGirl.create(:path, :user => @user, :company => @user.company)
		@section = FactoryGirl.create(:section, :path => @path)
		@task = FactoryGirl.create(:task, :section => @section)
    @user.enroll!(@path)
    @attr = {:task_id => @task.id, :content => "Comment content"}
	end
  
  it "should create a new instance given valid attributes" do
		@user.comments.create!(@attr)
	end

  describe "validation" do
    it "should require at task id" do
      @user.comments.new(@attr.delete("task_id")).should_not be_valid
    end
    
    it "should respond to content" do
      @user.comments.new(@attr).should respond_to(:content)
    end
    
    it "should reject a long content" do
      @user.comments.new(@attr.merge(:content => "A"*256)).should_not be_valid
    end
  
    describe "task associations" do
      before(:each) do
        @comment = @user.comments.create!(@attr)
      end

      it "should respond to task" do
        @comment.should respond_to(:task)
      end

      it "should respond with the right task" do
        @comment.task_id.should == @task.id
        @comment.task.should == @task
      end
      
      it "should reject association to un-owned tasks" do
        @other_task = FactoryGirl.create(:task)
        @user.comments.new(@attr.merge(:task_id => @other_task.id)).should_not be_valid
      end
      
      it "should reject association to unenrolled tasks" do
        other_path = FactoryGirl.create(:path, :user => @user, :company => @user.company)
        other_task = FactoryGirl.create(:task, :path => other_path)
        @user.comments.new(@attr.merge(:task_id => other_task.id)).should_not be_valid
      end
    end
     
    describe "user associations" do
      before(:each) do
        @comment = @user.comments.create!(@attr)
      end
      
      it "should respond to user" do
        @comment.should respond_to(:user)
      end

      it "should respond with the right user" do
        @comment.user_id.should == @user.id
        @comment.user.should == @user
      end
    end
	end
end
