require "spec_helper"
#Note: emails, last_email, last_email_to are defined elsewhere. Emails returns an array of emails.

describe EvaluationEnrollment do
  before :each do
    4.times { FactoryGirl.create(:path) }
    @group = FactoryGirl.create(:group)
    @creator = @group.users.first
    @evaluation = FactoryGirl.create(:evaluation, group: @group, user: @creator)
    @old_evaluation_enrollment = FactoryGirl.create(:evaluation_enrollment, evaluation: @evaluation, submitted_at: 10.days.ago)
  end
  
  describe "old evaluation submission" do    
    it "should result in 0 submissions" do
      EvaluationEnrollment.new_submissions(10.minutes.ago).size.should == 0
    end
    
    it "should result in 0 emails" do
      EvaluationEnrollment.send_all_submission_alerts(10.minutes.ago, true)
      emails.size.should == 0
    end
  end
  
  describe "1 new submission" do
    before :each do
      @evaluation_enrollment = FactoryGirl.create(:evaluation_enrollment, evaluation: @evaluation, submitted_at: 1.minute.ago)
    end
    
    it "should result in 1 induction" do
      EvaluationEnrollment.new_submissions(10.minutes.ago).size.should == 1
    end
    
    it "should result in 1 email" do
      EvaluationEnrollment.send_all_submission_alerts(10.minutes.ago, true)
      emails.size.should == 1
      last_email_to.should == @evaluation_enrollment.group.users.first.email
    end
  end
  
  describe "2 new submissions" do
    before :each do
      @evaluation_enrollment = FactoryGirl.create(:evaluation_enrollment, evaluation: @evaluation, submitted_at: 1.minute.ago)
      @evaluation_enrollment2 = FactoryGirl.create(:evaluation_enrollment, evaluation: @evaluation, submitted_at: 1.minute.ago)
    end
    
    it "should result in 2 inductions" do
      EvaluationEnrollment.new_submissions(10.minutes.ago).size.should == 2
    end
    
    it "should result in 2 emails" do
      EvaluationEnrollment.send_all_submission_alerts(10.minutes.ago, true)
      emails.size.should == 2
      last_email_to.should == @evaluation_enrollment.group.users.first.email
    end
  end
end