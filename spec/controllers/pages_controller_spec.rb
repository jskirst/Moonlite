require 'spec_helper'

describe PagesController do
	render_views
	
	describe "GET 'home'" do
		it "should be successful" do
			get 'home'
			response.should be_success
		end

		it "should have the right title" do
			get 'home'
			response.should have_selector("title", :content => "Project Moonlite | Home")
		end
		
		describe "when not signed in" do
			it "should have a link to the about page" do
				get 'home'
				response.should have_selector("a", :href => "/about")
			end
		end
		
		describe "when signed in" do
			before(:each) do
				@user = Factory(:user, :email => "test@user.com")
				@user.set_company_admin(true)
				test_sign_in(@user)
			end
		
			describe "enrolled paths" do
				describe "when they exist" do
					before(:each) do
						@path1 = Factory(:path, :name => "Path1", :user => @user, :company => @user.company)
						@path2 = Factory(:path, :name => "Path2", :user => @user, :company => @user.company)
						@path3 = Factory(:path, :name => "Path I'm not enrolled in", :user => @user, :company => @user.company)
            @user.enroll!(@path1)
            @user.enroll!(@path2)
					end
					
					it "should be displayed by name" do
						get 'home'
						response.should have_selector("a", :content => @path1.name)
						response.should have_selector("a", :content => @path2.name)
					end
				end
				
				describe "when they do not exist" do
					it "should instead have a message saying that exist" do
						get 'home'
						response.should have_selector("p", :content => "not currently enrolled")
					end
				end
			end
		end
	end
  
	describe "GET 'about'" do
		it "should be successful" do
			get 'about'
			response.should be_success
		end
		
		it "should have the right title" do
		  get 'about'
		  response.should have_selector("title", :content => "About")
		end
	end
	
	describe "GET 'invitation'" do
		it "should be successful" do
			get 'invitation'
			response.should be_success
		end
		
		it "should have the right title" do
			get 'invitation'
			response.should have_selector("title", :content => "Request an invite")
		end
		
		describe "email" do
			it "should send an alert e-mail" do
				email = "fake_email_for_testing@123456atesting.com"
				email_to = "jskirst@gmail.com"
				get 'invitation', :pages => { :email => email }
				ActionMailer::Base.deliveries.last.to.should == [email_to]
			end
		end
	end
end
