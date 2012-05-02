require 'spec_helper'

describe "Rewards" do
	before(:each) do
		@company = FactoryGirl.create(:company)
		@attr = { :name => "Think Geek Rhyme Vigilante",
			:description => "Its a wonderful nigh, you gotta take it from me.",
			:image_url => "http://www.google.com/fuckyou",
			:points => 5 }
	end
	
	it "should create a new instance given valid attributes" do
		@company.rewards.create!(@attr)
	end
	
	describe "attributes" do
		before(:each) do
			@reward = @company.rewards.create(@attr)
		end	
		
		it "should include a name" do
			@reward.should respond_to(:name)
		end
		
		it "should include an description" do
			@reward.should respond_to(:description)
		end		
		
		it "should include an points" do
			@reward.should respond_to(:points)
		end
		
		it "should include an image_url" do
			@reward.should respond_to(:image_url)
		end
	end
	
	describe "company association" do
		before(:each) do
			@reward = @company.rewards.create(@attr)
		end
		
		it "should have a company attribute" do
			@reward.should respond_to(:company)
		end
		
		it "should have the right associated company" do
			@reward.company_id.should == @company.id
			@reward.company.should == @company
		end
	end
	
	describe "validations" do
		it "should require a company id" do
			Reward.new(@attr).should_not be_valid
		end
		
		it "should require non-blank name" do
			@company.rewards.build(@attr.merge(:name => "")).should_not be_valid
		end
		
		it "should require non-blank description" do
			@company.rewards.build(@attr.merge(:description => "")).should_not be_valid
		end
		
		it "should require non-blank image_url" do
			@company.rewards.build(@attr.merge(:image_url => "")).should_not be_valid
		end
		
		it "should require non-nil points" do
			@company.rewards.build(@attr.merge(:points => nil)).should_not be_valid
		end		
		
		it "should reject long names" do
			@company.rewards.build(@attr.merge(:name => "a"*256)).should_not be_valid
		end
		
		it "should reject long descriptions" do
			@company.rewards.build(@attr.merge(:description => "a"*256)).should_not be_valid
		end
		
		it "should reject long image_urls" do
			@company.rewards.build(@attr.merge(:image_url => "a"*256)).should_not be_valid
		end
		
		it "should a reject points value thats too high" do
			@company.rewards.build(@attr.merge(:points => 100000000000)).should_not be_valid
		end
	end
end
