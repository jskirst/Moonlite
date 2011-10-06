# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe "Users" do
  
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
	
	describe "Name validations" do
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
	
	describe "Email validations" do	
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
		
		it "should reject valid emails" do
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
	
	describe "Password validations" do
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
	
	describe "Password encryption" do
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
	
	describe "User authentication" do
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
		
		it "should be convertible to an admin" do
			@user.toggle!(:admin)
			@user.should be_admin
		end
	end
	
	describe "Microposts association" do
		before(:each) do
			@user = User.create(@attr)
			@mp1 = Factory(:micropost, :user => @user, :created_at => 1.day.ago)
			@mp2 = Factory(:micropost, :user => @user, :created_at => 1.hour.ago)
		end
		
		it "should have a microposts attribute" do
			@user.should respond_to(:microposts)
		end
		
		it "should have the right microposts in the right order" do
			@user.microposts.should == [@mp2, @mp1]
		end
		
		it "should destroy associated microposts" do
			@user.destroy
			[@mp1, @mp2].each do |mp|
				Micropost.find_by_id(mp.id).should be_nil
			end
		end
		
		describe "status feed" do
			it "should respond" do
				@user.should respond_to(:feed)
			end
			
			it "should show the users microposts" do
				@user.feed.include?(@mp1).should be_true
				@user.feed.include?(@mp2).should be_true
			end
			
			it "should contain only the users microposts" do
				@mp3 = Factory(:micropost, 
					:user => Factory(:user, :email => "not@t.com"))
				@user.feed.include?(@mp3).should be_false
			end
		end
	end
end
