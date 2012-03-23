require 'spec_helper'

describe "Tasks" do
	before(:each) do
		@user = Factory(:user)
		@user.set_company_admin(true)
		@path = Factory(:path, :user => @user, :company => @user.company)
		@section = Factory(:section, :path => @path)
		visit signin_path
		fill_in :email, :with => @user.email
		fill_in :password, :with => @user.password
		click_button #goes to user page (path index)
		click_link "Explore"
		click_link @path.name.gsub(" ","_")
		click_link "Edit"
		click_link "Sections"
		click_link "Edit"
		click_link "Tasks"
		click_link "New Task"
	end
	
	describe 'creation' do
		describe "failure" do
			it "should not make a new task" do
				lambda do
					fill_in :task_question, :with => ""
					fill_in :task_answer1, :with => ""
					fill_in :task_answer2, :with => ""
					click_button "Save"
					response.should render_template("tasks/task_form")
					response.should have_selector("div#error_explanation")
				end.should_not change(Task, :count)
			end
		end
		
		describe "success" do
			it "should make a new task" do
				lambda do
					fill_in :task_question, :with => "Test question"
					fill_in :task_answer1, :with => "Test answer"
					fill_in :task_answer2, :with => "Test answer2"
					click_button "Save"
					response.should render_template('sections/edit_tasks')
					response.should have_selector("div.success")
				end.should change(Task, :count).by(1)
			end
			
			it "should make a new task and start new when click Save and New" do
				lambda do
					fill_in :task_question, :with => "Test question"
					fill_in :task_answer1, :with => "Test answer"
					fill_in :task_answer2, :with => "Test answer2"
					click_button "Save and New"
					response.should render_template("tasks/task_form")
					response.should have_selector("div.success")
				end.should change(Task, :count).by(1)
			end
		end
	end
end
