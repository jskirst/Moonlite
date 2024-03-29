require 'spec_helper'

describe 'Password Reset' do
  before :each do
    @user = init_metabright
    ActionMailer::Base.deliveries = []
  end

  it "should send email to user with link to reset passoword" do
  	visit signin_path
  	click_on "Reset it here."

  	expect_content("Enter your email address and we'll send you a password reset link right away!")
  	fill_in "user_email", with: @user.email
  	click_on "Reset"

  	expect_content("Email sent to #{@user.email}.")
  	ActionMailer::Base.deliveries.size.should == 1
  	email = ActionMailer::Base.deliveries.last
  	email.to.should include(@user.email)
  	email.body.encoded.should include(finish_reset_path(t: @user.signup_token))
  end

  it "should send email to user with link to reset passoword" do
  	visit finish_reset_path(t: @user.signup_token)
  	expect_content("Please enter and confirm your new password.")
  	fill_in "session_password", with: "newpassword"
  	fill_in "session_password_confirmation", with: "newpassword"
  	find("input[descriptor='save-and-sign-in']").click

  	expect_content(@user.name)
  end
end