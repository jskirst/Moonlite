require 'spec_helper'

describe "User" do
	before(:each) do
		@attr = { 
			:name => "Example User", 
			:email => "user@example.com",
			:password => "foobar",
			:password_confirmation => "foobar"
		}
	end
	
	it "should create a new instance given valid attributes" do
		User.create!(@attr)
	end
	
	describe "name validations" do
		it "should require a name" do
			user = User.new(@attr.merge(:name => ""))
			user.should_not be_valid
		end
		
		it "should reject names that are too long" do
			long_name = 'a' * 55
			user = User.new(@attr.merge(:name => long_name))
			user.should_not be_valid
		end
	end
	
	describe "email validations" do	
		it "should require an email" do
			user = User.new(@attr.merge(:email => ""))
			user.should_not be_valid
		end
		
		it "should accept valid emails" do
			emails = %w[user@example.com THE_USER@foo.bar.org first.last@foo.jp]
			emails.each do |email|
				user = User.new(@attr.merge(:email => email))
				user.should be_valid
			end
		end
		
		it "should reject invalid emails" do
			emails = %w[user@example,com THE_USER_AT.foo.bar.org first.last@foo.]
			emails.each do |email|
				user = User.new(@attr.merge(:email => email))
				user.should_not be_valid
			end
		end
		
		it "should reject a duplicate email address" do
			upcased_email = @attr[:email].upcase
			User.create!(@attr.merge(:email => upcased_email))
			user = User.new(@attr)
			user.should_not be_valid
		end
	end
	
	describe "password validations" do
		it "should require a password and confirmation" do
			pw = ""
			pw_conf = ""
			user = User.new(@attr.merge(:password => pw, :password_confirmation => pw_conf))
			user.should_not be_valid
		end
		
		it "should require a matching password confirmation" do
			pw_conf = "not foobar"
			user = User.new(@attr.merge(:password_confirmation => pw_conf))
			user.should_not be_valid
		end
		
		it "should reject short passwords" do
			pw = "a" * 5
			pw_conf = pw
			user = User.new(@attr.merge(:password => pw, :password_confirmation => pw_conf))
			user.should_not be_valid
		end
		
		it "should reject long passwords" do
			pw = "a" * 41
			pw_conf = pw
			user = User.new(@attr.merge(:password => pw, :password_confirmation => pw_conf))
			user.should_not be_valid
		end
	end
	
	describe "password encryption" do
		before(:each) do
			@user = User.create!(@attr)
		end
		
		it "should be true if the passwords match" do
			@user.has_password?(@attr[:password]).should be_true
		end
		
		it "should have an encrypted password attribute" do
			@user.should respond_to(:encrypted_password)
		end
	end
	
	describe "user authentication" do
		it "should reject a bad password" do
			user = User.authenticate(@attr[:email], "badpassword")
			user.should be_nil
		end
		
		it "should reject a nil email" do
			user = User.authenticate("bademail", @attr[:password])
			user.should be_nil
		end
		
		it "should accept a good combination" do
			user = User.authenticate(@attr[:email], @attr[:password])
			user.should == @user
		end
	end
	
	describe "admin attribute" do
		before(:each) do
			@user = User.create!(@attr)
		end
		
		it "should respond to admin" do
			@user.should respond_to(:admin)
		end
		
		it "should not be an admin by default" do
			@user.should_not be_admin
		end
		
		it "should be convertible to true" do
			@user.toggle!(:admin)
			@user.should be_admin
		end
		
		it "should not change the password when toggled" do
			lambda do
				@user.toggle!(:admin)
				@user.reload
			end.should_not change(@user, :encrypted_password)
		end
		
		it "should not change the salt when toggled" do
			current_salt = @user.salt
			@user.toggle!(:admin)
			@user.reload
			@user.salt.should == current_salt
		end
	end
	
	describe "paths" do
		before(:each) do
			@user = User.create!(@attr)
			@path1 = Factory(:path, :user => @user, :created_at => 1.day.ago)
			@path2 = Factory(:path, :user => @user, :created_at => 1.hour.ago)
		end
		
		it "should have a paths attribute" do
			@user.should respond_to(:paths)
		end
		
		it "should have the right paths in the right order" do
			@user.paths.should == [@path2, @path1]
		end
		
		it "should destroy associated paths" do
			@user.destroy
			[@path1, @path2].each do |p|
				Path.find_by_id(p.id).should be_nil
			end
		end
	end
	
	describe "enrollments" do
		before(:each) do
			@user = User.create!(@attr)
			@path = Factory(:path, :user => @user)
		end
		
		it "should have a paths attribute" do
			@user.should respond_to(:enrollments)
		end
		
		it "should respond to enrolled? method" do
			@user.should respond_to(:enrolled?)
		end
		
		it "should respond to enroll! method" do
			@user.should respond_to(:enroll!)
		end
		
		it "should in enroll in a path" do
			@user.enroll!(@path)
			@user.should be_enrolled(@path)
		end
		
		it "should not say enrolled if it isn't" 
		# do
			# @user.should_not be_enrolled(@path)
		# end
		
		it "should respond to unenroll!" do
			@user.should respond_to(:unenroll!)
		end
		
		it "should unenroll from a path" do
			@user.enroll!(@path)
			@user.unenroll!(@path)
			@user.should_not be_enrolled(@path)
		end
	end
	
	describe "enrolled paths" do
		before(:each) do
			@user = User.create!(@attr)
			@path = Factory(:path, :user => @user)
		end
		
		it "should have a paths attribute" do
			@user.should respond_to(:enrolled_paths)
		end
	end
	
	describe "completed tasks" do
		before(:each) do
			@user = User.create!(@attr)
			@path = Factory(:path, :user => @user)
			@task1 = Factory(:task, :path => @path, :points => 1)
			@task2 = Factory(:task, :path => @path, :points => 2)
		end
		
		it "should have a completed tasks attribute" do
			@user.should respond_to(:completed_tasks)
		end
		
		it "should respond to completed? method" do
			@user.should respond_to(:completed?)
		end
		
		#TODO: REMOVE
		# it "should respond to complete! method" do
			# @user.should respond_to(:complete!)
		# end
		
		#TODO: REMOVE
		# it "should compelete a task" do
			# @user.complete!(@task1)
			# @user.should be_completed(@task1)
		# end
		
		it "should not say enrolled if it isn't" do
			@user.should_not be_completed(@task2)
		end
	end
end
