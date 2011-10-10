require 'spec_helper'

describe "Tasks" do
	before(:each) do
		#Sign in
		@user = Factory(:user)
		visit signin_path
		fill_in :email, :with => @user.email
		fill_in :password, :with => @user.password
		click_button #goes to user page (path index)
		
		#Create a path
		visit all_paths_path
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
					visit all_paths_path
					click_link @path_name
					click_link "Add a question"
					fill_in :task_question, :with => ""
					fill_in :task_answer, :with => ""
					fill_in :task_rank, :with => ""
					click_button
					response.should render_template('tasks/new')
					response.should have_selector("div#error_explanation")
				end.should_not change(Task, :count)
			end
		end
		
		describe "success" do
			it "should make a new task" do
				lambda do
					visit all_paths_path
					click_link @path_name
					click_link "Add a question"
					fill_in :task_question, :with => "Test question"
					fill_in :task_answer, :with => "Test answer"
					fill_in :task_rank, :with => "1"
					click_button
					response.should render_template('paths/show')
					response.should have_selector("div.success")
				end.should change(Task, :count).by(1)
			end
		end
		
		describe "failure followed by success" do
			it "should make a new task" do
				lambda do
					visit all_paths_path
					click_link @path_name
					click_link "Add a question"
					fill_in :task_question, :with => ""
					fill_in :task_answer, :with => ""
					fill_in :task_rank, :with => ""
					click_button
					fill_in :task_question, :with => "Test question"
					fill_in :task_answer, :with => "Test answer"
					fill_in :task_rank, :with => "1"
					click_button
					response.should render_template('paths/show')
					response.should have_selector("div.success")
				end.should change(Task, :count).by(1)
			end
		end
	end
end
