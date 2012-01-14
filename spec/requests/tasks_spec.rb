require 'spec_helper'

describe "Tasks" do
	before(:each) do
		#Sign in
		@user = Factory(:user)
		@company = Factory(:company)
		Factory(:company_user, :user => @user, :company => @company)
		visit signin_path
		fill_in :email, :with => @user.email
		fill_in :password, :with => @user.password
		click_button #goes to user page (path index)
		
		#Create a path
		click_link "Paths"
		click_link "Create new Path"
		@path_name = "New Path Name"
		fill_in :path_name, :with => @path_name
		fill_in :path_description, :with => "Test value"
		click_button #goes to home page (path index)
	end
	
	describe 'creation' do
		describe "failure" do
			it "should not make a new task" do
				lambda do
					click_link "Paths"
					click_link @path_name
					click_link "Edit"
					click_link "Add Question"
					fill_in :task_question, :with => ""
					fill_in :task_answer1, :with => ""
					fill_in :task_points, :with => ""
					click_button
					response.should render_template("tasks/task_form")
					response.should have_selector("div#error_explanation")
				end.should_not change(Task, :count)
			end
		end
		
		describe "success" do
			it "should make a new task" do
				lambda do
					click_link "Paths"
					click_link @path_name
					click_link "Edit"
					click_link "Add Question"
					fill_in :task_question, :with => "Test question"
					fill_in :task_answer1, :with => "Test answer"
					fill_in :task_points, :with => "1"
					click_button
					response.should render_template('paths/show')
					response.should have_selector("div.success")
				end.should change(Task, :count).by(1)
			end
		end
		
		describe "failure followed by success" do
			it "should make a new task" do
				lambda do
					click_link "Paths"
					click_link @path_name
					click_link "Edit"
					click_link "Add Question"
					fill_in :task_question, :with => ""
					fill_in :task_answer1, :with => ""
					fill_in :task_points, :with => ""
					click_button
					fill_in :task_question, :with => "Test question"
					fill_in :task_answer1, :with => "Test answer"
					select "1", :from => "Correct answer"
					select "5", :from => "Points"
					click_button
					response.should render_template('paths/show')
					response.should have_selector("div.success")
				end.should change(Task, :count).by(1)
			end
		end
	end
end
