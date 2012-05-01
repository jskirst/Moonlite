require 'spec_helper'

describe "Info Resources" do
	before(:each) do
		@user = Factory(:user)
		@path = Factory(:path, :user => @user, :company => @user.company)
    @section = Factory(:section, :path => @path)
		@attr = { :section_id => @section.id, :info_type => "text", :description => "resource description", :link => "http://www.wikipedia.com" }
	end
	
	it "should create a new instance given valid attributes" do
		InfoResource.create!(@attr)
	end
	
	describe "attributes" do
		before(:each) do
			@info_resource = InfoResource.create!(@attr)
		end
		
		it "should include a description" do
			@info_resource.should respond_to(:description)
		end		
		
		it "should include a link" do
			@info_resource.should respond_to(:link)
		end
    
    it "should include an info_type" do
			@info_resource.should respond_to(:info_type)
		end
	end
	
	describe "object associations" do
		before(:each) do
			@info_resource = InfoResource.create!(@attr)
		end
		
		it "should have a section attribute" do
			@info_resource.should respond_to(:section)
		end
		
		it "should have the right associated section" do
			@info_resource.section_id.should == @section.id
			@info_resource.section.should == @section
		end
	end
	
	describe "validations" do
		it "should require at least one section/path/task id" do
			InfoResource.new(@attr.merge(:section_id => "")).should_not be_valid
		end
		
		it "should reject long descriptions" do
			InfoResource.new(@attr.merge(:description => "a"*256)).should_not be_valid
		end
		
		it "should reject long links" do
			InfoResource.new(@attr.merge(:link => "a"*256)).should_not be_valid
		end
	end
end
