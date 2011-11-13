require "spec_helper"

describe Mailer do
	describe 'welcome' do
		before(:each) do
			@company_user = Factory(:company_user)
			@mail = Mailer.welcome({:email => @company_user.email, :token1 => @company_user.token1})
		end

		it 'renders the subject' do
		  @mail.subject.should == 'Hello World'
		end

		it 'renders the receiver email' do
		  @mail.to.should == [@company_user.email]
		end

		it 'renders the sender email' do
		  @mail.from.should == ['registration@projectmoonlite.com']
		end
	end
end
