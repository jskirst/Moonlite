require 'spec_helper'

describe ReportsController do
	render_views
	
	before(:each) do
		@user = Factory(:user)
		@path = Factory(:path, :user => @user, :company => @user.company)
		@section = Factory(:section, :path => @path)
	end
	
	describe "access controller" do
		describe "when not signed in" do
			it "should deny access to 'dashboard'" do
				get :dashboard
				response.should redirect_to signin_path
			end

			it "should deny access to 'details'" do
				get :details, :path_id => @path.id
				response.should redirect_to signin_path
			end					
		end
		
		describe "when signed in as a regular user" do
			before(:each) do
				test_sign_in(@user)
			end
			
			it "should deny access to 'new'" do
				get :dashboard
				response.should redirect_to root_path
			end
			
			it "should deny access to 'details'" do
				get :details, :path_id => @path.id
				response.should redirect_to root_path
			end
		end
		
		describe "when signed in as company admin" do
			before(:each) do
				@user.set_company_admin(true)
				test_sign_in(@user)
			end
			
			it "should allow access to 'new'" do
				get :dashboard
				response.should be_success
			end
			
			it "should allow access to 'details'" do
				get :details, :path_id => @path.id
				response.should be_success
			end
		end
		
		describe "when signed in as admin" do
			before(:each) do
				@user.toggle!(:admin)
				test_sign_in(@user)
			end
			
			it "should deny access to 'new'" do
				get :dashboard
				response.should redirect_to root_path
			end
			
			it "should deny access to 'details'" do
				get :details, :path_id => @path.id
				response.should redirect_to root_path
			end
		end
	end

	describe "GET 'dashboard'" do
		before(:each) do
			@user.set_company_admin(true)
			test_sign_in(@user)
		end
	
		it "should be successful" do
			get :dashboard
			response.should be_success
		end

		it "should have the right title" do
			get :dashboard
			response.should have_selector("title", :content => "Dashboard")
		end
		
		describe "with invalid integer time argument" do
			it "should default to 7 days" do
				get :dashboard, :time => "abc"
				response.should have_selector("a.selected-time", :content => "7 days")
			end
		end
	end
	
	describe "GET 'details'" do
		before(:each) do
			@user.set_company_admin(true)
			test_sign_in(@user)
		end
		
		describe "failure" do
			describe "with no path argument" do
				it "should redirect to dashboard" do
					get :details, :path_id => nil
					response.should redirect_to dashboard_path
				end
			end
			
			describe "with bad path argument" do
				it "should redirect to dashboard" do
					get :details, :path_id => "10000000000"
					response.should redirect_to dashboard_path
				end
			end
		end
		
		describe "success" do
			it "should be successful" do
				get :details, :path_id => @path.id
				response.should be_success
			end

			it "should have the right title" do
				get :details, :path_id => @path.id
				response.should have_selector("title", :content => "Details")
			end
			
			describe "correctly answered question table" do
				before(:each) do
          @user.enroll!(@path)
					@task1 = Factory(:task, :section => @section)
					@task2 = Factory(:task, :section => @section)
					@task3 = Factory(:task, :section => @section)
					
					3.times do |n|
						Factory(:completed_task, :task => @task1, :user => @user, :status_id => 1)
					end
					
					2.times do |n|
						Factory(:completed_task, :task => @task2, :user => @user, :status_id => 1)
					end
					
					1.times do |n|
						Factory(:completed_task, :task => @task3, :user => @user, :status_id => 1)
					end
					
				end
				
				it "should display the rank of the correctly answered questions" do
					get :details, :path_id => @path.id
					response.should have_selector("td#correct_rank_"+@task1.id.to_s, :content => "1")
					response.should have_selector("td#correct_rank_"+@task2.id.to_s, :content => "2")
					response.should have_selector("td#correct_rank_"+@task3.id.to_s, :content => "3")
				end
				
				it "should display the question of the correctly answered questions" do
					get :details, :path_id => @path.id
					response.should have_selector("td#correct_question_"+@task1.id.to_s, :content => @task1.question)
					response.should have_selector("td#correct_question_"+@task2.id.to_s, :content => @task2.question)
					response.should have_selector("td#correct_question_"+@task3.id.to_s, :content => @task3.question)
				end
				
				it "should display the count of the correctly answered questions" do
					get :details, :path_id => @path.id
					response.should have_selector("td#correct_count_"+@task1.id.to_s, :content => "3")
					response.should have_selector("td#correct_count_"+@task2.id.to_s, :content => "2")
					response.should have_selector("td#correct_count_"+@task3.id.to_s, :content => "1")
				end
			end
			
			describe "incorrectly answered question table" do
				before(:each) do
          @user.enroll!(@path)
					@task1 = Factory(:task, :section => @section)
					@task2 = Factory(:task, :section => @section)
					@task3 = Factory(:task, :section => @section)
					
					3.times do |n|
						Factory(:completed_task, :task => @task1, :user => @user, :status_id => 0)
					end
					
					2.times do |n|
						Factory(:completed_task, :task => @task2, :user => @user, :status_id => 0)
					end
					
					1.times do |n|
						Factory(:completed_task, :task => @task3, :user => @user, :status_id => 0)
					end
				end
				
				it "should properly rank the incorrectly answered questions by count" do
					get :details, :path_id => @path.id
					response.should have_selector("td#incorrect_rank_"+@task1.id.to_s, :content => "1")
					response.should have_selector("td#incorrect_rank_"+@task2.id.to_s, :content => "2")
					response.should have_selector("td#incorrect_rank_"+@task3.id.to_s, :content => "3")
				end
				
				it "should display the question of the incorrectly answered questions" do
					get :details, :path_id => @path.id
					response.should have_selector("td#incorrect_question_"+@task1.id.to_s, :content => @task1.question)
					response.should have_selector("td#incorrect_question_"+@task2.id.to_s, :content => @task2.question)
					response.should have_selector("td#incorrect_question_"+@task3.id.to_s, :content => @task3.question)
				end
				
				it "should display the count of the incorrectly answered questions" do
					get :details, :path_id => @path.id
					response.should have_selector("td#incorrect_count_"+@task1.id.to_s, :content => "3")
					response.should have_selector("td#incorrect_count_"+@task2.id.to_s, :content => "2")
					response.should have_selector("td#incorrect_count_"+@task3.id.to_s, :content => "1")
				end
			end
		end
	end
end