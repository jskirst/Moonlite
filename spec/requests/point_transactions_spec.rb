require 'spec_helper'

describe "PointTransactions" do
	before(:each) do
		@user = Factory(:user)
		@user.toggle!(:admin)
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
			it "should complete a task and list the point transaction on the transactions page"
			# it "should complete a task and list them on the " do
				# click_link "Solve Problems"
				# response.should render_template("paths/continue")
				# response.should have_selector("p", :content => @task1.question)
				# choose "completed_task_answer1"
				# click_button "Next"
				# choose "completed_task_answer1"
				# click_button "Next"
				# choose "completed_task_answer1"
				# click_button "Next"
				# click_link "Transactions"
				#response.should have_selector("li", :content => @task1.question)
			# end
		end
	end
end
