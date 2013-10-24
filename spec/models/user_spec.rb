require "spec_helper"
#Note: emails, last_email, last_email_to are defined elsewhere. Emails returns an array of emails.

describe User do
  describe "creation" do
    it "should save email, name, password" do
      user = User.create! do |u|
        u.name = "TestDude"
        u.email = "test@t.com"
        u.password = "asasdfsdfasd"
      end
    end
  end
  
  describe "email alerts" do
    before :each do
      @user = FactoryGirl.create(:user)
    end
    
    describe "sent 0 emails" do
      it "should result in 0 sent_email records" do
        SentEmail.count.should == 0
      end
      it "should result in 0 emails" do
        last_email.should be_nil
      end
    end
  
    describe "sent 1 email" do
      before :each do
        @user.send_test_alert
      end
      it "should result in 1 sent_email records" do
        SentEmail.count.should == 1
        SentEmail.last.user_id.should == @user.id
        SentEmail.last.content.should == "Test alert"
      end
      it "should result in 1 email" do
        emails.size.should == 1
      end
    end
    
    describe "sent 3 emails" do
      before :each do
        3.times do
          @user.send_test_alert
        end
      end
      it "should result in 1 sent_email records" do
        SentEmail.count.should == 3
      end
      it "should result in 1 email" do
        emails.size.should == 3
      end
    end
  
    describe "sent MAX_DAILY_EMAILS(#{User::MAX_DAILY_EMAILS}) emails" do
      before :each do
        User::MAX_DAILY_EMAILS.times do
          @user.send_test_alert
        end
      end
      it "should result in MAX_DAILY_EMAILS(#{User::MAX_DAILY_EMAILS}) sent_email records" do
        SentEmail.count.should == User::MAX_DAILY_EMAILS
      end
      it "should result in MAX_DAILY_EMAILS(#{User::MAX_DAILY_EMAILS}) emails" do
        emails.size.should == User::MAX_DAILY_EMAILS
      end
    end
  
    describe "sent MAX_DAILY_EMAILS(#{User::MAX_DAILY_EMAILS}) + 1 emails" do
      before :each do
        (User::MAX_DAILY_EMAILS+1).times do
          @user.send_test_alert
        end
      end
      it "should result in MAX_DAILY_EMAILS(#{User::MAX_DAILY_EMAILS}) sent_email records" do
        SentEmail.count.should == User::MAX_DAILY_EMAILS
      end
      it "should result in MAX_DAILY_EMAILS(#{User::MAX_DAILY_EMAILS}) emails" do
        emails.size.should == User::MAX_DAILY_EMAILS
      end
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
  
    describe "sent 1 email when emails_today maxed out and last_email_sent_at was yesterday" do
      before :each do
        @user.last_email_sent_at = 24.hours.ago
        @user.emails_today = User::MAX_DAILY_EMAILS
        @user.save
        @user.send_test_alert
      end
      it "should result in 1 sent_email records" do
        SentEmail.count.should == 1
      end
      it "should result in 1 emails" do
        emails.size.should == 1
      end
      it "should reset emails today to 1" do
        @user.emails_today.should == 1
      end
      it "should reset last_email_sent_at to today" do
        @user.last_email_sent_at.to_date.today?.should be_true
      end
    end
  end

  describe "newsletters" do
    before :each do
      reset_email
      @u = FactoryGirl.create(:user)
      User.count.should == 1
    end

    it "should not send newsletter to locked user" do
      @u.update_attribute(:locked_at, Time.now)
      User.send_all_newsletters("newsletter_10232013", "Big News!")
      @u.reload
      @u.last_email_sent_at.should be_nil
      @u.emails_today.should == 0
      emails.size.should == 0
      SentEmail.count.should == 0
    end

    it "should not send newsletter to unsubscribed user" do
      @u.notification_settings.update_attribute(:inactive, true)
      User.send_all_newsletters("newsletter_10232013", "Big News!")
      @u.reload
      @u.last_email_sent_at.should be_nil
      @u.emails_today.should == 0
      emails.size.should == 0
      SentEmail.count.should == 0
    end

    it "should not send newsletter to user with MAX_DAILY_EMAILS" do
      time = Time.now - 1.minute
      @u.update_attribute(:last_email_sent_at, time)
      @u.update_attribute(:emails_today, User::MAX_DAILY_EMAILS)
      User.send_all_newsletters("newsletter_10232013", "Big News!")
      @u.reload
      @u.emails_today.should == User::MAX_DAILY_EMAILS
      emails.size.should == 0
      SentEmail.count.should == 0
    end

    it "should not send newsletter to user that has turned off weekely emails" do
      @u.notification_settings.update_attribute(:weekly, false)
      User.send_all_newsletters("newsletter_10232013", "Big News!")
      @u.reload
      @u.last_email_sent_at.should be_nil
      @u.emails_today.should == 0
      emails.size.should == 0
      SentEmail.count.should == 0
    end

    it "should send one newsletter to all users valid users" do
      4.times do
        FactoryGirl.create(:user)
      end
      User.count.should == 5
      User.send_all_newsletters("newsletter_10232013", "Big News!")
      @u.reload
      @u.last_email_sent_at.should_not be_nil
      @u.emails_today.should == 1
      emails.size.should == 5
      SentEmail.count.should == 5
    end
  end
end