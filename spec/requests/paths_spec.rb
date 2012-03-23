require 'spec_helper'

describe "Explore" do
	before(:each) do
		@user = Factory(:user)
		@user.set_company_admin(true)
		visit signin_path
		fill_in :email, :with => @user.email
		fill_in :password, :with => @user.password
		click_button
    visit root_path
	end
	
	describe 'creation' do
		describe "failure" do
			it "should not make a new path" do
				lambda do
					click_link "Create"
					fill_in :path_name, :with => ""
					click_button
					response.should render_template('paths/new')
					response.should have_selector("div#error_explanation")
				end.should_not change(Path, :count)
			end
		end
		
		describe "success" do
			it "should make a new path" do
				lambda do
					click_link "Create"
					fill_in :path_name, :with => "NAME"
					click_button
				end.should change(Path, :count).by(1)
			end
		end
	end
	
	# describe "question upload" do
		# before(:each) do
			# @path = Factory(:path, :user => @user, :company => @user.company)
		# end
	
		# describe "success" do
			# before(:each) do
				# @file_name = "test_upload_file.csv"
				# @file_name = "test.txt"
				# @file_path = "/public/misc/"
			# end
		
			# it "should add all questions to a path" do
				# visit paths_path
				# click_link @path.name
				# click_link "Edit"
				# click_link "Upload Questions"
				# Rails.logger.debug File.join(Rails.root, @file_path, @file_name)
				# attach_file "path_file", File.join(Rails.root, @file_path, @file_name), "text/csv"
				# click_button "Submit"
				# response.should be_success
			# end
		# end
	# end
	
end
