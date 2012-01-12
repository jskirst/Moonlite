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
				@creator = Factory(:user, :email => "creator@user.com")
				test_sign_in(@user)
			end
		
			describe "enrolled paths" do
				describe "when they exist" do
					before(:each) do
						@path1 = Factory(:path, :name => "Path1", :user => @creator)
						@path2 = Factory(:path, :name => "Path2", :user => @creator)
						@path3 = Factory(:path, :name => "Path I'm not enrolled in", :user => @creator)
						
						@enrollment = Factory(:enrollment, :path => @path1, :user => @user)
						@enrollment = Factory(:enrollment, :path => @path2, :user => @user)
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
		  response.should have_selector("title", :content => "Project Moonlite | About")
		end
	end
end
