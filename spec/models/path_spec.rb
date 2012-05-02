require 'spec_helper'

describe "Paths" do
	before(:each) do
		@user = FactoryGirl.create(:user)
		@attr = { :name => "Test name", :description => "Test description", :created_at => 1.day.ago }
	end
	
	it "should create a new instance given valid attributes" do
		@user.paths.create!(@attr)
	end
	
	describe "attributes" do
		it "should require a user id" do
			Path.new(@attr).should_not be_valid
		end
		
		it "should require non-blank name" do
			@user.paths.build(:name => "").should_not be_valid
		end
		
		it "should require non-blank description" do
			@user.paths.build(:description => "").should_not be_valid
		end
		
		it "should reject long name" do
			@user.paths.build(:name => "a"*141).should_not be_valid
		end
		
		it "should reject long description" do
			@user.paths.build(:description => "a"*2501).should_not be_valid
		end

		it "should respond to image_url" do
			@user.paths.create!(@attr).should respond_to(:image_url)
		end
		
		it "should respond with path_pic set to default if image_url is not set" do
			@user.paths.create!(@attr).path_pic.should == "/images/default_path_pic.jpg"
		end
		
		it "should respond with is_public set to false if not set" do
			@user.paths.create!(@attr).is_public.should == false
		end
		
		it "should respond to purchased_path_id" do
			@user.paths.create!(@attr).should respond_to(:purchased_path_id)
		end
		
		it "should respond to is_published set to false if not set" do
			@user.paths.create!(@attr).should respond_to(:is_published)
		end
		
		it "should respond with is_published set to false if not set" do
			@user.paths.create!(@attr).is_published.should == false
		end
		
		it "should respond to is_purchaseable" do
			@user.paths.create!(@attr).should respond_to(:is_purchaseable)
		end
		
		it "should respond with is_purchaseable set to false if not set" do
			@user.paths.create!(@attr).is_purchaseable.should == false
		end
	end
	
	describe "user associations" do
		before(:each) do
			@path = @user.paths.create(@attr)
		end
		
		it "should have a user attribute" do
			@path.should respond_to(:user)
		end
		
		it "should have the right associated user" do
			@path.user_id.should == @user.id
			@path.user.should == @user
		end
	end
	
	describe "company association" do
		before(:each) do
			@path = @user.paths.build(@attr)
			@other_company = FactoryGirl.create(:company, :name => "Other Company")
		end
		
		it "should have a company attribute" do
			@path.should respond_to(:company)
		end
		
		it "should not require a company" do
			@path.company = nil
			@path.should be_valid
		end
		
		it "should reject a company the user doesn't belong to" do
			@path.company = @other_company
			@path.should_not be_valid
		end
		
		it "should accept a company the user belongs to" do
			@path.company = @company
			@path.should be_valid
		end
	end
	
	describe "section associations" do
		before(:each) do
			@path = FactoryGirl.create(:path, :user => @user)
			@section1 = FactoryGirl.create(:section, :path => @path)
			@section2 = FactoryGirl.create(:section, :path => @path)
      @path.reload
		end
		
		it "should have a sections attribute" do
			@path.should respond_to(:sections)
		end
		
		it "should return the right sections in the right order (lowest position first)" do
      @path.sections.should == [@section1, @section2]
		end
		
		it "should destroy associated tasks" do
			Rails::logger.debug "FUCK"
      @path.destroy
			[@section1, @section2].each do |s|
				Section.find_by_id(s.id).should be_nil
			end
		end
	end
end
