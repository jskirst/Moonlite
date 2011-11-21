require 'spec_helper'

describe "Users" do
	describe "Signup" do
		describe "Failure" do
			it "Should not make a new user" do
				lambda do
					visit signup_path
					fill_in "Name",				:with => ""
					fill_in "Email",			:with => ""
					fill_in "Password",			:with => ""
					fill_in "Confirm password",	:with => ""
					click_button "Sign up"
					response.should have_selector("div#error_explanation", :content => "Name can't be blank")
				end.should_not change(User, :count)
			end
		end
		
		describe "Success" do
			it "Should make a new user" do
				lambda do
					visit signup_path
					fill_in "Name",				:with => "Eddard Stark"
					fill_in "Email",			:with => "random@stark.com"
					fill_in "Password",			:with => "winteriscoming"
					fill_in "Confirm password",	:with => "winteriscoming"
					click_button "Sign up"
					response.should have_selector("div.flash.success",:content => "Welcome")
				end.should change(User, :count).by(1)
			end
		end
	end
end
