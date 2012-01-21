require 'spec_helper'

describe "Company" do
	before(:each) do
		@attr = { 
			:name => "Example Company",
		}
	end
	
	it "should create a new instance given valid attributes" do
		Company.create!(@attr)
	end
	
	describe "name validations" do
		it "should require a name" do
			Company.new(@attr.merge(:name => "")).should_not be_valid
		end
		
		it "should reject names that are too long" do
			Company.new(@attr.merge(:name => 'a' * 101)).should_not be_valid
		end
	end
	
	describe "paths" do
		before(:each) do
			@user = Factory(:user)
			@path1 = Factory(:path, :user => @user, :company => @user.company)
			@path2 = Factory(:path, :user => @user, :company => @user.company)
		end
		
		it "should have a paths attribute" do
			@user.company.should respond_to(:paths)
		end
		
		it "should have the right paths in the right order" do
			@user.company.paths.should == [@path2, @path1]
		end
		
		it "should destroy associated paths" do
			@user.company.destroy
			[@path1, @path2].each do |p|
				Path.find_by_id(p.id).should_not be_nil
			end
		end
	end
end
