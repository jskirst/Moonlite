require 'spec_helper'

describe NotificationSettings do
	before :each do
		@user = FactoryGirl.create(:user)
	end

  describe "sent 1 interaction email with interactions turned off" do
    before :each do
      @user.notification_settings.update_attribute(:interaction, false)
      @user.send_test_alert(:interaction)
    end
    it "should result in 0 sent_email records" do
      SentEmail.count.should == 0
    end
    it "should result in 0 emails" do
      emails.size.should == 0
    end
  end

  describe "sent 1 powers email with interactions turned off" do
    before :each do
      @user.notification_settings.update_attribute(:powers, false)
      @user.send_test_alert(:powers)
    end
    it "should result in 0 sent_email records" do
      SentEmail.count.should == 0
    end
    it "should result in 0 emails" do
      emails.size.should == 0
    end
  end

  describe "sent 1 weekly email with interactions turned off" do
    before :each do
      @user.notification_settings.update_attribute(:weekly, false)
      @user.send_test_alert(:weekly)
    end
    it "should result in 0 sent_email records" do
      SentEmail.count.should == 0
    end
    it "should result in 0 emails" do
      emails.size.should == 0
    end
  end
end