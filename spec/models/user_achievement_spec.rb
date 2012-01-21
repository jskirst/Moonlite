require 'spec_helper'
#TODO : Stop creation if user not enrolled

describe UserAchievement do
	before(:each) do
		@user = Factory(:user)
		@achievement = Factory(:achievement)
		
		@attr = { :achievement_id => @achievement.id }
		@user_achievement = @user.user_achievements.build(@attr)
	end
	
	it "should create a new instance given valid attributes" do
		@user_achievement.save!
	end
	
	describe "validations" do
		it "should require a user_id" do
			@user_achievement.user_id = nil
			@user_achievement.should_not be_valid
		end
		
		it "should require a achievement_id" do
			@user_achievement.achievement_id = nil
			@user_achievement.should_not be_valid
		end
		
		it "should have a user attribute" do
			@user_achievement.should respond_to(:user)
		end
		
		it "should have the right user" do
			@user_achievement.user_id.should == @user.id
			@user_achievement.user.should == @user
		end
		
		it "should respond to achievement attribute" do
			@user_achievement.should respond_to(:achievement)
		end
		
		it "should have the right achievement" do
			@user_achievement.achievement_id.should == @achievement.id
			@user_achievement.achievement.should == @achievement
		end
	end
end
