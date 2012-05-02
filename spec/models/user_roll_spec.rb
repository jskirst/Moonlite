require 'spec_helper'

describe "UserRoll" do
	before(:each) do
		@company = FactoryGirl.create(:company)
		@attr = { :name => "Think Geek Rhyme Vigilante" }
	end
	
	it "should create a new instance given valid attributes" do
		@company.user_rolls.create!(@attr)
	end
	
	describe "attributes" do
		before(:each) do
			@user_roll = @company.user_rolls.create(@attr)
		end	
		
		it "should include a name" do
			@user_roll.should respond_to(:name)
		end
	end
	
	describe "company association" do
		before(:each) do
			@user_roll = @company.user_rolls.create(@attr)
		end
		
		it "should have a company attribute" do
			@user_roll.should respond_to(:company)
		end
		
		it "should have the right associated company" do
			@user_roll.company_id.should == @company.id
			@user_roll.company.should == @company
		end
	end
	
	describe "users association" do
		before(:each) do
			@user_roll = @company.user_rolls.create(@attr)
			@user = FactoryGirl.create(:user, :company => @company, :user_roll => @user_roll)
			@user2 = FactoryGirl.create(:user, :company => @company, :user_roll => @user_roll)
		end
		
		it "should have a company attribute" do
			@user_roll.should respond_to(:users)
		end
		
		it "should have the right associated users" do
			@user_roll.users.should == [@user, @user2]
		end
		
		it "should not allower user roll deletion until all associated users are gone" do
			@user_roll.destroy.should	be_false
		end
	end
	
	describe "validations" do
		it "should require a company id" do
			UserRoll.new(@attr).should_not be_valid
		end
		
		it "should require non-blank name" do
			@company.user_rolls.build(@attr.merge(:name => "")).should_not be_valid
		end
	end
end
