require 'spec_helper'

describe "Company" do
	before(:each) do
		@attr = { 
			:name => "Example User", 
		}
	end
	
	it "should create a new instance given valid attributes" do
		Company.create!(@attr)
	end
	
	describe "name validations" do
		it "should require a name" do
			user = User.new(@attr.merge(:name => ""))
			user.should_not be_valid
		end
		
		it "should reject names that are too long" do
			long_name = 'a' * 100
			user = User.new(@attr.merge(:name => long_name))
			user.should_not be_valid
		end
	end
	
	# describe "paths" do
		# before(:each) do
			# @user = User.create!(@attr)
			# @path1 = Factory(:path, :user => @user, :created_at => 1.day.ago)
			# @path2 = Factory(:path, :user => @user, :created_at => 1.hour.ago)
		# end
		
		# it "should have a paths attribute" do
			# @user.should respond_to(:paths)
		# end
		
		# it "should have the right paths in the right order" do
			# @user.paths.should == [@path2, @path1]
		# end
		
		# it "should destroy associated paths" do
			# @user.destroy
			# [@path1, @path2].each do |p|
				# Path.find_by_id(p.id).should be_nil
			# end
		# end
	# end
end
