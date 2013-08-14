require "spec_helper"
#Note: emails, last_email, last_email_to are defined elsewhere. Emails returns an array of emails.

describe Group do
  describe "old group" do
    before :each do
      @old_group = FactoryGirl.create(:group)
      @old_group.created_at = 1.hour.ago
      @old_group.save!
    end
    
    it "should result in 0 emails" do
      Group.send_all_welcome_emails(10.minutes.ago, true)
      last_email.should be_nil
    end
  end
  
  describe "1 inducted submitted answer" do
    before :each do
      @sa.update_attribute(:promoted_at, Time.now)
    end
    
    it "should result in 1 induction" do
      SubmittedAnswer.inductions(1.hour.ago).size.should == 1
    end
    
    it "should result in 1 email" do
      SubmittedAnswer.send_all_induction_alerts(1.hour.ago, true)
      emails.size.should == 1
      last_email_to.should == @user.email
    end
  end
  
  describe "2 inducted submitted answers from for the same user" do
    before :each do
      @sa.update_attribute(:promoted_at, Time.now)
      @sa2.update_attribute(:promoted_at, Time.now)
    end
    
    it "should result in 2 inductions" do
      SubmittedAnswer.inductions(1.hour.ago).size.should == 2
    end
    
    it "should result in 2 emails" do
      SubmittedAnswer.send_all_induction_alerts(1.hour.ago, true)
      emails.size.should == 2
      last_email_to.should == @user.email
    end
  end
  
  describe "2 inducteds submitted answers from for 2 differen users" do
    before :each do
      @sa.update_attribute(:promoted_at, Time.now)
      @sa3.update_attribute(:promoted_at, Time.now)
    end
    
    it "should result in 2 inductions" do
      SubmittedAnswer.inductions(1.hour.ago).size.should == 2
    end
    
    it "should result in 2 emails" do
      SubmittedAnswer.send_all_induction_alerts(1.hour.ago, true)
      emails.size.should == 2
      emails.first.to.first.should == @user.email
      last_email_to.should == @user2.email
    end
  end
end