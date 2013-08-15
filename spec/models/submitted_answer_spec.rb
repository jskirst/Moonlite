require "spec_helper"
#Note: emails, last_email, last_email_to are defined elsewhere. Emails returns an array of emails.

describe SubmittedAnswer do
  before :each do
    @task = FactoryGirl.create(:task)
    @task2 = FactoryGirl.create(:task)
    
    @user = FactoryGirl.create(:user)
    @user.enroll!(@task.path)
    @user.enroll!(@task2.path)
    
    @user2 = FactoryGirl.create(:user)
    @user2.enroll!(@task.path)
    
    @sa = SubmittedAnswer.new(content: Faker::Lorem.sentence(12))
    @sa.task_id = @task.id
    @sa.save!
    ct = @user.completed_tasks.create!(enrollment_id: @user.enrolled?(@task.path).id, task_id: @task.id, status_id: 1, submitted_answer_id: @sa.id)
    
    @sa2 = SubmittedAnswer.new(content: Faker::Lorem.sentence(12))
    @sa2.task_id = @task2.id
    @sa2.save!
    ct = @user.completed_tasks.create!(enrollment_id: @user.enrolled?(@task2.path).id, task_id: @task2.id, status_id: 1, submitted_answer_id: @sa2.id)
    
    @sa3 = SubmittedAnswer.new(content: Faker::Lorem.sentence(12))
    @sa3.task_id = @task.id
    @sa3.save!
    ct = @user2.completed_tasks.create!(enrollment_id: @user2.enrolled?(@task.path).id, task_id: @task.id, status_id: 1, submitted_answer_id: @sa3.id)
  end
  
  describe "uninducted submitted answer" do
    it "should result in 0 emails" do
      SubmittedAnswer.send_all_induction_alerts(1.hour.ago, true)
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