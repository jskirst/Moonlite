require 'spec_helper'

describe CompanyUser do
	before(:each) do
		@user = Factory(:user, :company_user => nil)
		@company = Factory(:company)
		@attr = { :company_id => @company, :email => "test@test.com", :is_admin => true }
		@company_user = @company.company_users.create!(@attr.merge(:user_id => @user.id))
	end
	
	describe "attributes" do
		it "should have a user attribute" do
			@company_user.should respond_to(:user)
		end
		
		it "should produce the right user" do
			@company_user.user_id.should == @user.id
			@company_user.user.should == @user
		end
		
		it "should respond to company attribute" do
			@company_user.should respond_to(:company)
		end
		
		it "should have the right company" do
			@company_user.company_id.should == @company.id
			@company_user.company.should == @company
		end
		
		it "should have a token1 attribute" do
			@company_user.should respond_to(:token1)
		end
		
		it "should have a token2 attribute" do
			@company_user.should respond_to(:token2)
		end
		
		it "should have an is_admin attribute" do
			@company_user.should respond_to(:is_admin)
		end
	end
	
	describe "validations" do
		before(:each) do
			@company
		end
		
		describe "for company_id" do
			it "should require a company_id" do
				@company_user.company_id = nil
				@company_user.should_not be_valid
			end
			
			it "should reject a duplicate registration" do
				CompanyUser.new(:company_id => @company.id, :user_id => @company.id).should_not be_valid
			end
		end
		
		describe "for email" do	
			it "should require an email" do
				company_user = CompanyUser.new(@attr.merge(:email => ""))
				company_user.should_not be_valid
			end
			
			it "should accept valid emails" do
				emails = %w[user@example.com THE_USER@foo.bar.org first.last@foo.jp]
				emails.each do |email|
					company_user = CompanyUser.new(@attr.merge(:email => email))
					company_user.should be_valid
				end
			end
			
			it "should reject invalid emails" do
				emails = %w[user@example,com THE_USER_AT.foo.bar.org first.last@foo.]
				emails.each do |email|
					company_user = CompanyUser.new(@attr.merge(:email => email))
					company_user.should_not be_valid
				end
			end
			
			it "should reject a duplicate email address" do
				upcased_email = @attr[:email].upcase
				company_user = CompanyUser.new(@attr.merge(:email => upcased_email))
				company_user.should_not be_valid
			end
		end
		
		describe "for automatic token creation" do
			before(:each) do
				@company_user.save!
				@company_user.reload
			end
			
			it "should be retrievable by token1" do
				@cu = CompanyUser.find(:first, :conditions => ["token1 = ?", @company_user.token1])
				@cu.should_not be_nil
			end	
			
			it "should be retrievable by token2" do
				@cu = CompanyUser.find(:first, :conditions => ["token2 = ?", @company_user.token2])
				@cu.should_not be_nil
			end
		
			it "should create a valid token1 after creation" do
				@company_user.token1.gsub(/a-zA-Z0-9/,'').length.should == 15
			end
			
			it "should create a valid token2 after creation" do
				@company_user.token2.gsub(/a-zA-Z0-9/,'').length.should == 15
			end
			
			it "should create new unique tokens" do
				other_company_user = @company.company_users.build(@attr.merge(:email => "new_email@t.com"))
				other_company_user.save!
				other_company_user.token1.should_not == @company_user.token1
				other_company_user.token2.should_not == @company_user.token2
			end
		end
		
		describe "is admin" do
			it "should not be blank" do
				company_user = CompanyUser.new(@attr.merge(:is_admin => ""))
				company_user.should_not be_valid
			end
			
			it "should not be nil" do
				company_user = CompanyUser.new(@attr.merge(:is_admin => nil))
				company_user.should_not be_valid
			end
		end
	end
	
	describe "email" do
		it "should send a welcome e-mail to the right user" do
			@company_user = Factory(:company_user)
			@company_user.send_invitation_email
			ActionMailer::Base.deliveries.last.to.should == [@company_user.email]
		end
	end
end
