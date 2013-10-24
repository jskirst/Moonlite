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

  describe "email" do
    before :each do
      reset_email
      @user = FactoryGirl.create(:user)
      User.count.should == 1
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

    describe "with old values for emails_today and last_email_sent_at" do
      before :each do
        @user.update_attribute(:last_email_sent_at, Time.now - 2.days)
        @user.update_attribute(:emails_today, User::MAX_DAILY_EMAILS)
      end
      it "sending should set last_email_sent_at to today and emails_today to 1" do
        @user.send_test_alert
        @user.reload
        @user.last_email_sent_at.to_date.should == Time.now.to_date
        @user.emails_today.should == 1
      end
    end

    describe "newsletters" do
      it "should not send newsletter to locked user" do
        @user.update_attribute(:locked_at, Time.now)
        User.send_all_newsletters("newsletter_10232013", "Big News!")
        @user.reload
        @user.last_email_sent_at.should be_nil
        @user.emails_today.should == 0
        emails.size.should == 0
        SentEmail.count.should == 0
      end

      it "should not send newsletter to unsubscribed user" do
        @user.notification_settings.update_attribute(:inactive, true)
        User.send_all_newsletters("newsletter_10232013", "Big News!")
        @user.reload
        @user.last_email_sent_at.should be_nil
        @user.emails_today.should == 0
        emails.size.should == 0
        SentEmail.count.should == 0
      end

      it "should not send newsletter to user with MAX_DAILY_EMAILS" do
        time = Time.now - 1.minute
        @user.update_attribute(:last_email_sent_at, time)
        @user.update_attribute(:emails_today, User::MAX_DAILY_EMAILS)
        User.send_all_newsletters("newsletter_10232013", "Big News!")
        @user.reload
        @user.emails_today.should == User::MAX_DAILY_EMAILS
        emails.size.should == 0
        SentEmail.count.should == 0
      end

      it "should not send newsletter to user that has turned off weekely emails" do
        @user.notification_settings.update_attribute(:weekly, false)
        User.send_all_newsletters("newsletter_10232013", "Big News!")
        @user.reload
        @user.last_email_sent_at.should be_nil
        @user.emails_today.should == 0
        emails.size.should == 0
        SentEmail.count.should == 0
      end

      it "should not send newsletter to users with email @metabright.com" do
        @user.update_attribute(:enable_administration, false)
        @user.destroy
        @user = User.create_with_nothing
        User.send_all_newsletters("newsletter_10232013", "Big News!")
        @user.reload
        @user.last_email_sent_at.should be_nil
        @user.emails_today.should == 0
        emails.size.should == 0
        SentEmail.count.should == 0
      end

      it "should send one newsletter to all users valid users" do
        4.times do
          FactoryGirl.create(:user)
        end
        User.count.should == 5
        User.send_all_newsletters("newsletter_10232013", "Big News!")
        @user.reload
        @user.last_email_sent_at.should_not be_nil
        @user.emails_today.should == 1
        emails.size.should == 5
        SentEmail.count.should == 5
      end
    end
  end
end