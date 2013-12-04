require "spec_helper"
#Note: emails, last_email, last_email_to are defined elsewhere. Emails returns an array of emails.

describe Group do
  describe "creation" do
    it "should succeed with minimum fields" do
      @group = Group.new
      @group.name = "My Blog"
      @group.creator_name = "Blogger Man"
      @group.creator_email = "bloggerman@t.com"
      @group.creator_password = "a1b2c3d4"
    end
  end

  describe ".price(percent_off = nil)" do
    it "should return standard price without percent_off" do
      @group = Group.new
      @group.plan_type = Group::SINGLE_PLAN
      @group.price.should == 19.99
    end

    it "should return standard price without percent_off" do
      @group = Group.new
      @group.plan_type = Group::SINGLE_PLAN
      @group.price(50).should == 9.99
    end
  end
  
  describe "emails" do
    before :each do    
      @old_group = FactoryGirl.create(:group)
      @old_group.created_at = 1.hour.ago
      @old_group.save!
    end

    describe "old group" do    
      it "should result in 0 emails" do
        Group.send_all_welcome_emails(10.minute.ago, true)
        last_email.should be_nil
      end
    end
    
    describe "1 new group" do
      before :each do
        @group = FactoryGirl.create(:group)
      end
      
      it "should result in 1 group" do
        Group.new_groups(10.minutes.ago).size.should == 1
      end
      
      it "should result in 1 email" do
        Group.send_all_welcome_emails(10.minutes.ago, true)
        emails.size.should == 1
        last_email_to.should == @group.users.first.email
      end
    end
    
    describe "2 new groups" do
      before :each do
        @group = FactoryGirl.create(:group)
        @group2 = FactoryGirl.create(:group)
      end
      
      it "should result in 2 new groups" do
        Group.new_groups(10.minutes.ago).size.should == 2
      end
      
      it "should result in 2 emails" do
        Group.send_all_welcome_emails(10.minutes.ago, true)
        emails.size.should == 2
        last_email_to.should == @group2.users.first.email
      end
    end
  end
end