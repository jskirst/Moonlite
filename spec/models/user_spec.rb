require 'spec_helper'

describe "User" do
	before(:each) do
		@company = FactoryGirl.create(:company)
		@user_roll = FactoryGirl.create(:user_roll, :company => @company)
		@attr = { 
			:name => "Example User", 
			:email => "user@example.com",
			:password => "foobar",
			:password_confirmation => "foobar",
			:user_roll_id => @user_roll.id
		}
	end
	
	it "should create a new instance given valid attributes" do
		@company.users.create!(@attr)
	end
	
	describe "name validations" do
		it "should require a name" do
			@company.users.build(@attr.merge(:name => "")).should_not be_valid
		end
		
		it "should reject names that are too long" do
			@company.users.build(@attr.merge(:name => 'a' * 55)).should_not be_valid
		end
	end
	
	describe "email validations" do	
		it "should require an email" do
			@company.users.build(@attr.merge(:email => "")).should_not be_valid
		end
		
		it "should accept valid emails" do
			emails = %w[user@example.com THE_USER@foo.bar.org first.last@foo.jp]
			emails.each do |email|
				user = @company.users.build(@attr.merge(:email => email))
				user.should be_valid
			end
		end
		
		it "should reject invalid emails" do
			emails = %w[user@example,com THE_USER_AT.foo.bar.org first.last@foo.]
			emails.each do |email|
				user = @company.users.build(@attr.merge(:email => email))
				user.should_not be_valid
			end
		end
		
		it "should reject a duplicate email address" do
			@company.users.create!(@attr.merge(:email => @attr[:email].upcase))
			@company.users.build(@attr).should_not be_valid
		end
	end
	
	describe "password validations" do
		it "should require a password and confirmation" do
			@company.users.build(@attr.merge(:password => "", :password_confirmation => "")).should_not be_valid
		end
		
		it "should require a matching password confirmation" do
			@company.users.build(@attr.merge(:password_confirmation => "not foobar")).should_not be_valid
		end
		
		it "should reject short passwords" do
			pw = "a" * 5
			@company.users.build(@attr.merge(:password => pw, :password_confirmation => pw)).should_not be_valid
		end
		
		it "should reject long passwords" do
			pw = "a" * 41
			@company.users.build(@attr.merge(:password => pw, :password_confirmation => pw)).should_not be_valid
		end
	end
	
	describe "password encryption" do
		before(:each) do
			@user = @company.users.create!(@attr)
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
			User.authenticate(@attr[:email], "badpassword").should be_nil
		end
		
		it "should reject a nil email" do
			User.authenticate("bademail", @attr[:password]).should be_nil
		end
		
		it "should accept a good combination" do
			User.authenticate(@attr[:email], @attr[:password]).should == @user
		end
	end
	
	describe "admin attribute" do
		before(:each) do
			@user = @company.users.create!(@attr)
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
	
	describe "image url validations" do
		it "should respond to image_url" do
			@company.users.create!(@attr).should respond_to(:image_url)
		end
		
		it "should respond with profile_pic set to default if image_url is not set" do
			@company.users.create!(@attr).profile_pic.should == "/images/default_profile_pic.jpg"
		end
	end

	describe "company_admin?" do
		it "should respond with false if user is not company admin" do
			@company.users.create!(@attr).company_admin.should be_false
		end
		
		# it "should respond with true if user is company admin" do
			# user = FactoryGirl.create(:user)
			# user.company_user.toggle!(:is_admin)
			# user.company_admin?.should be_true
		# end
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
			@user = @company.users.create!(@attr)
			@path1 = FactoryGirl.create(:path, :user => @user, :company => @user.company, :created_at => 1.day.ago)
			@path2 = FactoryGirl.create(:path, :user => @user, :company => @user.company, :created_at => 1.hour.ago)
		end
		
		it "should have a paths attribute" do
			@user.should respond_to(:paths)
		end
		
		it "should have the right paths in the right order" do
			@user.paths.to_a.include?(@path1).should == true
			@user.paths.to_a.include?(@path2).should == true
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
			@user = @company.users.create!(@attr)
			@path = FactoryGirl.create(:path, :user => @user, :company => @user.company)
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
		
		it "enroll? should return true if user is enrolled" do
			@user.enroll!(@path)
			@user.enrolled?(@path).should == true
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
			FactoryGirl.create(:enrollment, :path => @path, :user => @user)
			@user.unenroll!(@path)
			Enrollment.find(:all, :conditions => ["path_id = ? and user_id = ?", @path.id, @user.id]).should be_empty
		end
	end
	
	describe "enrolled paths" do
		before(:each) do
			@user = @company.users.create!(@attr)
			@path = FactoryGirl.create(:path, :user => @user, :company => @user.company)
		end
		
		it "should have a paths attribute" do
			@user.should respond_to(:enrolled_paths)
		end
	end
	
	describe "completed tasks" do
		before(:each) do
			@user = @company.users.create!(@attr)
      @path = FactoryGirl.create(:path, :user => @user, :company => @user.company)
      @user.enroll!(@path)
      @section = FactoryGirl.create(:section, :path => @path)
			@task1 = FactoryGirl.create(:task, :section => @section)
			@task2 = FactoryGirl.create(:task, :section => @section)
			@completed_task = FactoryGirl.create(:completed_task, :task => @task1, :user => @user)
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
			@user = @company.users.create!(@attr)
			@path = FactoryGirl.create(:path, :company => @company, :user => @user)
			@section = FactoryGirl.create(:section, :path => @path)
			@task = FactoryGirl.create(:task, :section => @section)
			@reward = FactoryGirl.create(:reward, :company => @user.company)
			@user.enroll!(@path)
		end
		
		describe "award_points" do
			it "should add task's points to earned points" do
				@user.award_points(@task, @task.points)
				@user.earned_points.should == @task.points
			end
				
			it "should add task's points to the appropriate enrollment's total_points" do
				@user.award_points(@task, @task.points)
				@user.enrollments.find_by_path_id(@task.section.path.id).total_points.should == @task.points
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
