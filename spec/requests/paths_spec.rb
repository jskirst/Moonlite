require 'spec_helper'

describe "Paths" do
	before(:each) do
		@user = Factory(:user)
		visit signin_path
		fill_in :email, :with => @user.email
		fill_in :password, :with => @user.password
		click_button
	end
	
	describe 'creation' do
		describe "failure" do
			it "should not make a new path" do
				lambda do
					visit all_paths_path
					click_link "Create new Path"
					fill_in :path_name, :with => ""
					fill_in :path_description, :with => ""
					click_button
					response.should render_template('paths/new')
					response.should have_selector("div#error_explanation")
				end.should_not change(Path, :count)
			end
		end
		
		describe "success" do
			it "should make a new path" do
				lambda do
					name = "NAME"
					description = "DESCRIPTION"
					visit all_paths_path
					click_link "Create new Path"
					fill_in :path_name, :with => name
					fill_in :path_description, :with => description
					click_button
					# TODO
					# response.should render_template('pages/home')
				end.should change(Path, :count).by(1)
			end
		end
	end
end
