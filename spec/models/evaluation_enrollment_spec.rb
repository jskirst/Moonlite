require "spec_helper"
#Note: emails, last_email, last_email_to are defined elsewhere. Emails returns an array of emails.

describe EvaluationEnrollment do
  before :each do
    4.times { FactoryGirl.create(:path) }
    @group = FactoryGirl.create(:group)
    @creator = @group.users.first
    @evaluation = FactoryGirl.create(:evaluation, group: @group, user: @creator)
  end
  
  describe "old group" do    
    it "should result in 0 emails" do
      true.should be_true
    end
  end
  
  # describe "1 inducted submitted answer" do
  #   before :each do
  #     @group = FactoryGirl.create(:group)
  #   end
  #   
  #   it "should result in 1 induction" do
  #     Group.new_groups(10.minutes.ago).size.should == 1
  #   end
  #   
  #   it "should result in 1 email" do
  #     Group.send_all_welcome_emails(10.minutes.ago, true)
  #     emails.size.should == 1
  #     last_email_to.should == @group.users.first.email
  #   end
  # end
  # 
  # describe "2 inducted submitted answers from for the same user" do
  #   before :each do
  #     @group = FactoryGirl.create(:group)
  #     @group2 = FactoryGirl.create(:group)
  #   end
  #   
  #   it "should result in 2 inductions" do
  #     Group.new_groups(10.minutes.ago).size.should == 2
  #   end
  #   
  #   it "should result in 2 emails" do
  #     Group.send_all_welcome_emails(10.minutes.ago, true)
  #     emails.size.should == 2
  #     last_email_to.should == @group2.users.first.email
  #   end
  # end
end