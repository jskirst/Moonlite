require 'spec_helper'

describe Leaderboard do
  before(:each) do
		@user = Factory(:user)
    @attr = {:user_id => @user.id, :completed_tasks => 0, :points => 0}
	end
	
	it "should create a new instance given valid attributes" do
		Leaderboard.create!(@attr)
	end
	
	describe "validations" do
    before(:each) do
      @leadboard = Leaderboard.new(@attr)
    end
  
		it "should require a user_id" do
			@leadboard.user_id = nil
			@leadboard.should_not be_valid
		end
    
    it "should have a user attribute" do
			@leadboard.should respond_to(:user)
		end
		
		it "should have the right user" do
			@leadboard.user_id.should == @user.id
			@leadboard.user.should == @user
		end
    
    it "should require a completed_tasks" do
			@leadboard.completed_tasks = nil
			@leadboard.should_not be_valid
		end
    
    it "should have a completed_tasks attribute" do
			@leadboard.should respond_to(:completed_tasks)
		end
    
    it "should have require an integer completed_tasks" do
			@leadboard.completed_tasks = "AAAAA"
			@leadboard.should_not be_valid
		end
    
    it "should require a score" do
			@leadboard.score = nil
			@leadboard.should_not be_valid
		end
    
    it "should have a score" do
			@leadboard.should respond_to(:score)
		end
    
    it "should require an integer score" do
			@leadboard.score = "AAAAA"
			@leadboard.should_not be_valid
		end
	end
end
