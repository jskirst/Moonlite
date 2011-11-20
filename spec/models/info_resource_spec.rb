require 'spec_helper'

describe "Info Resources" do
	before(:each) do
		@user = Factory(:user)
		@path = Factory(:path, :user => @user)
		@attr = { :description => "This is a resource description", :link => "http://www.wikipedia.com" }
	end
	
	it "should create a new instance given valid attributes" do
		@path.info_resources.create!(@attr)
	end
	
	describe "attributes" do
		before(:each) do
			@info_resource = @path.info_resources.create(@attr)
		end
		
		it "should include a description" do
			@info_resource.should respond_to(:description)
		end		
		
		it "should include a link" do
			@info_resource.should respond_to(:link)
		end
	end
	
	describe "path associations" do
		before(:each) do
			@info_resource = @path.info_resources.create(@attr)
		end
		
		it "should have a path attribute" do
			@info_resource.should respond_to(:path)
		end
		
		it "should have the right associated path" do
			@info_resource.path_id.should == @path.id
			@info_resource.path.should == @path
		end
	end
	
	describe "validations" do
	
		it "should require a path id" do
			InfoResource.new(@attr).should_not be_valid
		end
		
		it "should require non-blank description" do
			@path.info_resources.build(@attr.merge(:description => "")).should_not be_valid
		end
		
		it "should require non-blank link" do
			@path.info_resources.build(@attr.merge(:link => "")).should_not be_valid
		end
		
		it "should reject long descriptions" do
			@path.info_resources.build(@attr.merge(:description => "a"*256)).should_not be_valid
		end
		
		it "should reject long links" do
			@path.info_resources.build(@attr.merge(:link => "a"*256)).should_not be_valid
		end
	end
end
