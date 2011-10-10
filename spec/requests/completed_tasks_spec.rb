require 'spec_helper'

describe "CompletedTasks" do
	before(:each) do
		@user = Factory(:user)
		@path = Factory(:path, :user => @user)
		@task1 = Factory(:task, :path => @path)
		@task2 = Factory(:task, :path => @path)
		@task3 = Factory(:task, :path => @path)
		
		visit signin_path
		fill_in :email, :with => @user.email
		fill_in :password, :with => @user.password
		click_button #goes to user page (path index)
		visit all_paths_path
		click_link @path.name
		click_button "Take Path"
	end
	
	describe 'creation' do
		describe "success" do
			it "should complete a task" do
				lambda do
					click_link "Continue Path"
					response.should render_template("paths/continue")
					response.should have_selector("p", :content => @task1.question)
					fill_in "completed_task_answer", :with => @task1.answer
					click_button "Next"
					response.should have_selector("div.success")
					response.should have_selector("p", :content => @task2.question)
				end.should change(CompletedTask, :count).by(1)
			end
			
			it "should complete a task and then complete a path" do
				lambda do
					click_link "Continue Path"
					response.should render_template("paths/continue")
					response.should have_selector("p", :content => @task1.question)
					fill_in "completed_task_answer", :with => @task1.answer
					click_button "Next"
					fill_in "completed_task_answer", :with => @task2.answer
					click_button "Next"
					fill_in "completed_task_answer", :with => @task3.answer
					click_button "Next"
					response.should have_selector("p", :content => "Congratulations!")
				end.should change(CompletedTask, :count).by(3)
			end
		end
	end
end
