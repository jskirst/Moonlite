require "spec_helper"
#Note: emails, last_email, last_email_to are defined elsewhere. Emails returns an array of emails.

describe Visit do
  before :each do
    @user = FactoryGirl.create(:user)
    @visitor1 = FactoryGirl.create(:user)
    @visitor2 = FactoryGirl.create(:user)
    @visitor3 = FactoryGirl.create(:user)
    
    @user_url = "http://www.metabright.com/"+@user.username
    @visitor1_url = "http://www.metabright.com/"+@visitor1.username
    @visitor2_url = "http://www.metabright.com/"+@visitor2.username
    @visitor3_url = "http://www.metabright.com/"+@visitor3.username
  end
  
  describe "0 visits" do
    it "should result in 0 profile views" do
      Visit.profile_views(@user, 1.hour.ago).size.should == 0
    end
    it "should result in 0 emails" do
      Visit.send_all_visit_alerts(1.hour.ago, true)
      last_email.should be_nil
    end
  end
  
  describe "1 anonymous visit" do
    before :each do
      @visit = Visit.create!(visitor_id: rand(1000), request_url: @user_url)
    end
    it "should result in 0 profile views" do
      Visit.profile_views(@user, 1.hour.ago).size.should == 0
    end
    it "should result in 0 emails" do
      Visit.send_all_visit_alerts(1.hour.ago, true)
      last_email.should be_nil
    end
  end
    
  describe "1 visit" do
    before :each do
      @visit = Visit.create!(user_id: @visitor1.id, request_url: @user_url)
    end
    it "should result in 1 profile views" do
      Visit.profile_views(@user, 1.hour.ago).size.should == 1
    end
    it "should result in 1 email" do
      Visit.send_all_visit_alerts(1.hour.ago, true)
      emails.size.should == 1
      last_email_to.should == @user.email
      last_email.subject.should == "One person viewed your profile on MetaBright!"
    end
  end
  
  describe "2 visits to the same profile by the same person" do
    before :each do
      @visit = Visit.create!(user_id: @visitor1.id, request_url: @user_url)
      @visit = Visit.create!(user_id: @visitor1.id, request_url: @user_url)
    end
    it "should result in 1 profile views" do
      Visit.profile_views(@user, 1.hour.ago).size.should == 1
    end
    it "should result in 1 email" do
      Visit.send_all_visit_alerts(1.hour.ago, true)
      emails.size.should == 1
    end
  end
  
  describe "2 visits to the same profile by different people" do
    before :each do
      Visit.create!(user_id: @visitor1.id, request_url: @user_url)
      Visit.create!(user_id: @visitor2.id, request_url: @user_url)
    end
    it "should result in 2 profile views" do
      Visit.profile_views(@user, 1.hour.ago).size.should == 2
    end
    it "should result in 1 email" do
      Visit.send_all_visit_alerts(1.hour.ago, true)
      emails.size.should == 1
      last_email_to.should == @user.email
      last_email.subject.should == "2 people viewed your profile on MetaBright!"
    end
  end
  
  describe "2 visits to 2 different profiles" do
    before :each do
      Visit.create!(user_id: @visitor1.id, request_url: @user_url)
      Visit.create!(user_id: @user.id, request_url: @visitor1_url)
    end
    it "should result in 1 profile view each" do
      Visit.profile_views(@user, 1.hour.ago).size.should == 1
      Visit.profile_views(@visitor1, 1.hour.ago).size.should == 1
    end
    it "should result in 2 emails" do
      Visit.send_all_visit_alerts(1.hour.ago, true)
      emails.size.should == 2
      emails.first.to.first.should == @user.email
      emails.first.subject.should == "One person viewed your profile on MetaBright!"
      
      last_email_to.should == @visitor1.email
      emails.first.subject.should == "One person viewed your profile on MetaBright!"
    end
  end
end