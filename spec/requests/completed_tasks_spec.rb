require 'spec_helper'

describe "CompletedTasks" do
	before(:each) do
		@password = "current_password"
		@user = Factory(:user, :password => @password, :password_confirmation => @password)
		@user.set_company_admin(true)
		@path = Factory(:path, :user => @user, :company => @user.company)
		@section = Factory(:section, :path => @path)
		@task1 = Factory(:task, :section => @section)
		@task2 = Factory(:task, :section => @section)
		@task3 = Factory(:task, :section => @section)
		
		visit signin_path
		fill_in :email, :with => @user.email
		fill_in :password, :with => @user.password
		click_button #goes to user page (path index)
		visit paths_path
		click_link @path.name
		click_button "Enroll"
	end
	
	describe 'creation' do
		describe "success" do
			it "should complete a task" do
				lambda do
					click_link "Continue"
					response.should render_template("sections/continue")
					response.should have_selector("p", :content => @task1.question)
					choose "completed_task_answer1"
					click_button "Next"
					response.should have_selector("div.success")
					response.should have_selector("p", :content => @task2.question)
				end.should change(CompletedTask, :count).by(1)
			end
			
			it "should complete a task and then complete a path" do
				lambda do
					click_link "Continue"
					response.should render_template("sections/continue")
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
			
			it "should complete a task and not reset user's password" do
				click_link "Continue"
				response.should render_template("sections/continue")
				response.should have_selector("p", :content => @task1.question)
				choose "completed_task_answer1"
				click_button "Next"
				response.should have_selector("div.success")
				response.should have_selector("p", :content => @task2.question)
				click_link "Sign out"
				click_link "Sign in"
				visit signin_path
				fill_in :email, :with => @user.email
				fill_in :password, :with => @password
				click_button #goes to user page (path index)
				response.should have_selector("h1", :content => @user.name)
			end
		end
	end
end
