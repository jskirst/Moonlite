require 'spec_helper'

describe "CompletedTasks" do
	before(:each) do
		@user = Factory(:user)
		@company = Factory(:company)
		Factory(:company_user, :user => @user, :company => @company)
		@path = Factory(:path, :user => @user, :company => @company)
		@task1 = Factory(:task, :path => @path)
		@task2 = Factory(:task, :path => @path)
		@task3 = Factory(:task, :path => @path)
		
		visit signin_path
		fill_in :email, :with => @user.email
		fill_in :password, :with => @user.password
		click_button #goes to user page (path index)
		visit paths_path
		click_link @path.name
		click_button "Take Path"
	end
	
	describe 'creation' do
		describe "success" do
			it "should complete a task" do
				lambda do
					click_link "Solve Problems"
					response.should render_template("paths/continue")
					response.should have_selector("p", :content => @task1.question)
					choose "completed_task_answer1"
					click_button "Next"
					response.should have_selector("div.success")
					response.should have_selector("p", :content => @task2.question)
				end.should change(CompletedTask, :count).by(1)
			end
			
			it "should complete a task and then complete a path" do
				lambda do
					click_link "Solve Problems"
					response.should render_template("paths/continue")
					response.should have_selector("p", :content => @task1.question)
					choose "completed_task_answer1"
					click_button "Next"
					choose "completed_task_answer1"
					click_button "Next"
					choose "completed_task_answer1"
					click_button "Next"
					response.should have_selector("p", :content => "Congratulations!")
					response.should have_selector("dd", :content => @task1.answer1)
					response.should have_selector("dd", :content => @task2.answer1)
					response.should have_selector("dd", :content => @task3.answer1)
				end.should change(CompletedTask, :count).by(3)
			end
		end
	end
end
