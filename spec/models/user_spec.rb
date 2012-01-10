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

	describe "company_admin?" do
		it "should respond with false if user is not company admin" do
			@user = Factory(:user)
			@user.company_admin?.should be_false
		end
		
		it "should respond with true if user is company admin" do
			@user = Factory(:user)
			Factory(:company_user, :user => @user, :is_admin => "t")
			@user.company_admin?.should be_true
		end
	end
	
	describe "completed tasks" do
		it "should respond with all completed tasks"
		
		describe "completed?" do
			it "should respond with false if task not completed"
			
			it "should respond with true if the task is completed"
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
		
		it "enroll? should return nil if user is not enrolled" do
			@user.enrolled?(@path).should be_nil
		end
		
		it "enroll? should return the enrollment if user is enrolled" do
			enrollment = Factory(:enrollment, :path => @path, :user => @user)
			@user.enrolled?(@path).should == enrollment
		end
		
		it "should respond to enroll! method" do
			@user.should respond_to(:enroll!)
		end
		
		it "enroll! should in enroll in a path" do
			lambda do
				@user.enroll!(@path)
			end.should change(Enrollment, :count).by(1)
		end
		
		it "should respond to unenroll!" do
			@user.should respond_to(:unenroll!)
		end
		
		it "should unenroll from a path" do
			Factory(:enrollment, :path => @path, :user => @user)
			@user.unenroll!(@path)
			Enrollment.find(:all, :conditions => ["path_id = ? and user_id = ?", @path.id, @user.id]).should be_empty
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
			@user = Factory(:user)
			@path = Factory(:path, :user => @user)
			@task1 = Factory(:task, :path => @path, :points => 1)
			@completed_task = Factory(:completed_task, :task => @task1, :user => @user)
			@task2 = Factory(:task, :path => @path, :points => 2)
		end
		
		it "should have a completed tasks attribute" do
			@user.should respond_to(:completed_tasks)
		end
		
		describe "completed?" do
			it "should respond to successfully" do
				@user.should respond_to(:completed?)
			end
			
			it "should return nil if not task not completed" do
				@user.completed?(@task2).should be_nil
			end
			
			it "should return completed task if task is completed" do
				@user.completed?(@task1).should == @completed_task
			end
		end
	end
	
	describe "points" do
		before(:each) do
			@user = Factory(:user)
			@company = Factory(:company)
			Factory(:company_user, :user => @user, :company => @company)
			@path = Factory(:path, :user => @user)
			@task = Factory(:task, :path => @path)
			@reward = Factory(:reward, :company => @user.company)
			@enrollment = Factory(:enrollment, :path => @path, :user => @user)
		end
		
		describe "award_points" do
			it "should add task's points to earned points" do
				@user.award_points(@task)
				@user.earned_points.should == @task.points
			end
				
			it "should add task's points to the appropriate enrollment's total_points" do
				@user.award_points(@task)
				@user.enrollments.find_by_path_id(@path.id).total_points.should == @task.points
			end
		end		
		
		describe "debit_points" do
			it "should add points to spent points" do
				current_points = @user.spent_points
				@user.debit_points(@reward.points)
				@user.spent_points.should > current_points
				@user.spent_points.should == current_points + @reward.points
			end
		end
		
		describe "available_points" do
			it "should equal the earned points minus the spent points" do
				@user.earned_points = 100
				@user.spent_points = 25
				@user.available_points.should == 75
			end
		end
	end
end
