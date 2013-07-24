class GroupMailer < ActionMailer::Base
  default from: "Team MetaBright <team@metabright.com>"
  layout "mail"
  
  def signup(group, user)
    @group = group
    @user = user
  end
  
  def submission(evaluation_enrollment)
    @evaluation_enrollment = evaluation_enrollment
    @evaluation = @evaluation_enrollment.evaluation
  end
end
    