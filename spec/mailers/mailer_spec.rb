require "spec_helper"

describe Mailer do
	describe 'welcome' do
		before(:each) do
			@user = Factory(:user)
			@mail = Mailer.welcome({:email => @user.email, :signup_token => @user.signup_token})
		end

		it 'renders the subject' do
		  @mail.subject.should == 'Hello World'
		end

		it 'renders the receiver email' do
		  @mail.to.should == [@user.email]
		end

		it 'renders the sender email' do
		  @mail.from.should == ['registration@projectmoonlite.com']
		end
	end
end
