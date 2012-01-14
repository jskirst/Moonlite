require 'spec_helper'

describe "Paths" do
	before(:each) do
		@user = Factory(:user)
		@company = Factory(:company)
		Factory(:company_user, :user => @user, :company => @company)
		visit signin_path
		fill_in :email, :with => @user.email
		fill_in :password, :with => @user.password
		click_button
	end
	
	describe 'creation' do
		describe "failure" do
			it "should not make a new path" do
				lambda do
					click_link "Paths"
					click_link "Create new Path"
					fill_in "Name", :with => ""
					fill_in "Description", :with => ""
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
					visit paths_path
					click_link "Create new Path"
					fill_in "Name", :with => name
					fill_in "Description", :with => description
					click_button
					# TODO
					# response.should render_template('pages/home')
				end.should change(Path, :count).by(1)
			end
		end
	end
	
	describe "question upload" do
		before(:each) do
			@path = Factory(:path, :user => @user, :company => @company)
		end
	
		describe "success" do
			before(:each) do
				@file_name = "test_upload_file.csv"
				# @file_name = "test.txt"
				@file_path = "/public/misc/"
			end
		
			it "should add all questions to a path" do
				visit paths_path
				click_link @path.name
				click_link "Edit"
				click_link "Upload Questions"
				Rails.logger.debug File.join(Rails.root, @file_path, @file_name)
				attach_file "path_file", File.join(Rails.root, @file_path, @file_name), "text/csv"
				click_button "Submit"
				response.should be_success
			end
		end
	end
	
end
