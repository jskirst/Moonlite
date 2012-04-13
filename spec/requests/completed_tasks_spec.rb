require 'spec_helper'

describe "CompletedTasks" do
	before(:each) do
		@password = "current_password"
		@user = Factory(:user, :password => @password, :password_confirmation => @password)
		@user.set_company_admin(true)
		standard_setup(false)
		@task1 = Factory(:task, :section => @section)
		@task2 = Factory(:task, :section => @section)
		@task3 = Factory(:task, :section => @section)
    @section.reload
		
		visit signin_path
		fill_in :email, :with => @user.email
		fill_in :password, :with => @user.password
		click_button #goes to user page (path index)
		visit explore_path
		click_link @path.name.gsub(" ","_")
		click_button "Enroll"
	end
	
	describe 'creation' do
		describe "success" do
			it "should complete a task" do
				lambda do
					click_link "Start" #start path
          click_link "Start" #start section
					response.should render_template("sections/continue")
					response.should have_selector("p", :content => @task1.question)
					choose "completed_task_answer"+@task1.correct_answer.to_s
					click_button "Submit"
					response.should have_selector("p", :content => @task2.question)
				end.should change(CompletedTask, :count).by(1)
			end
			
			it "should complete a task and then complete a path" do
				lambda do
					click_link "Start" #start path
          click_link "Start" #start section
					response.should render_template("sections/continue")
					response.should have_selector("p", :content => @task1.question)
					choose "completed_task_answer"+@task1.correct_answer.to_s
					click_button "Submit"
          response.should have_selector("p", :content => @task2.question)
          choose "completed_task_answer"+@task2.correct_answer.to_s
					click_button "Submit"
          response.should have_selector("p", :content => @task3.question)
					choose "completed_task_answer"+@task3.correct_answer.to_s
					click_button "Submit"
					response.should have_selector("h2", :content => "Complete!")
					response.should have_selector("p", :content => @task1.question)
					response.should have_selector("p", :content => @task2.question)
					response.should have_selector("p", :content => @task3.question)
				end.should change(CompletedTask, :count).by(3)
			end
			
			it "should complete a task and not reset user's password" do
				click_link "Start" #start path
        click_link "Start" #start section
				response.should render_template("sections/continue")
				response.should have_selector("p", :content => @task1.question)
				choose "completed_task_answer"+@task1.correct_answer.to_s
				click_button "Submit"
				response.should have_selector("div.question")
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
