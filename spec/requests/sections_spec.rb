require 'spec_helper'

describe "Sections" do
	before(:each) do
		standard_setup(true, true, false)
		visit signin_path
		fill_in :email, :with => @user.email
		fill_in :password, :with => @user.password
		click_button #goes to user page (path index)
		click_link "Explore"
		click_link @path.name.gsub(" ","_")
		click_link "Edit"
		click_link "Sections"
		click_link "New Section"
	end
	
	describe 'creation' do
		describe "failure" do
			it "should not make a new section" do
				lambda do
					fill_in :section_name, :with => ""
					click_button "Next"
					response.should render_template("new")
					response.should have_selector("div#error_explanation")
				end.should_not change(Section, :count)
			end
		end
		
		describe "success" do
			it "should make a new section" do
				lambda do
					fill_in :section_name, :with => "Test Name"
					click_button "Next"
					response.should render_template("show")
					response.should have_selector("div.success")
				end.should change(Section, :count).by(1)
			end
		end
	end
end
