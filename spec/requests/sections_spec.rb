require 'spec_helper'

describe "Sections" do
	before(:each) do
		@user = Factory(:user)
		@user.set_company_admin(true)
		@path = Factory(:path, :user => @user, :company => @user.company)
		visit signin_path
		fill_in :email, :with => @user.email
		fill_in :password, :with => @user.password
		click_button #goes to user page (path index)
		click_link "Paths"
		click_link @path.name
		click_link "Add Section"
	end
	
	describe 'creation' do
		describe "failure" do
			it "should not make a new section" do
				lambda do
					fill_in :name, :with => ""
					fill_in :instructions, :with => ""
					click_button "Save"
					response.should render_template("sections/section_form")
					response.should have_selector("div#error_explanation")
				end.should_not change(Section, :count)
			end
		end
		
		describe "success" do
			it "should make a new section" do
				lambda do
					fill_in :name, :with => "Test Name"
					fill_in :instructions, :with => "Test instructions"
					click_button "Save"
					response.should render_template('sections/show')
					response.should have_selector("div.success")
				end.should change(Section, :count).by(1)
			end
			
			it "should make a new section and start new when click Save and New" do
				lambda do
					fill_in :name, :with => "Test Name"
					fill_in :instructions, :with => "Test instructions"
					click_button "Save and New"
					response.should render_template("sections/section_form")
					response.should have_selector("div.success")
				end.should change(Section, :count).by(1)
			end
		end
	end
end
