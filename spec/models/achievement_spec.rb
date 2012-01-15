require 'spec_helper'

describe "Achievement" do
	before(:each) do
		@user = Factory(:user)
		@path = Factory(:path, :user => @user)
		@attr = { :name => "This is an achievement",
			:description => "This is description of an achivement.",
			:criteria => "all",
			:points => 100 }
	end
	
	it "should create a new instance given valid attributes" do
		@path.achievements.create!(@attr)
	end
	
	describe "attributes" do
		before(:each) do
			@achievement = @path.achievements.create(@attr)
		end
		
		it "should include a name" do
			@achievement.should respond_to(:name)
		end		
		
		it "should include a description" do
			@achievement.should respond_to(:description)
		end
		
		it "should include an criteria" do
			@achievement.should respond_to(:criteria)
		end		
		
		it "should include an points" do
			@achievement.should respond_to(:points)
		end
	end
	
	describe "path associations" do
		before(:each) do
			@achievement = @path.achievements.create(@attr)
		end
		
		it "should have a path attribute" do
			@achievement.should respond_to(:path)
		end
		
		it "should have the right associated path" do
			@achievement.path_id.should == @path.id
			@achievement.path.should == @path
		end
	end
	
	describe "validations" do
		it "should require a path id" do
			Achievement.new(@attr).should_not be_valid
		end
		
		it "should require non-blank name" do
			@path.achievements.build(@attr.merge(:name => "")).should_not be_valid
		end
		
		it "should require non-blank description" do
			@path.achievements.build(@attr.merge(:description => "")).should_not be_valid
		end
		
		it "should require non-blank criteria" do
			@path.achievements.build(@attr.merge(:criteria => nil)).should_not be_valid
		end		
		
		it "should require non-nil points" do
			@path.achievements.build(@attr.merge(:points => nil)).should_not be_valid
		end
		
		it "should reject long names" do
			@path.achievements.build(@attr.merge(:name => "a"*256)).should_not be_valid
		end
		
		it "should reject long descriptions" do
			@path.achievements.build(@attr.merge(:description => "a"*256)).should_not be_valid
		end
	end
end
