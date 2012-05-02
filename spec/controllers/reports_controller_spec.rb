require 'spec_helper'

describe ReportsController do
	render_views
	
	before(:each) do
		@company = FactoryGirl.create(:company)
		@regular_user_roll = FactoryGirl.create(:user_roll, :company => @company, :enable_administration => "f")
		@admin_user_roll = FactoryGirl.create(:user_roll, :company => @company)
		@user = FactoryGirl.create(:user, :company => @company, :user_roll => @regular_user_roll)
		
		@category = FactoryGirl.create(:category, :company => @company)
		@path = FactoryGirl.create(:path, :user => @user, :company => @user.company, :category => @categoy)
		@section = FactoryGirl.create(:section, :path => @path)
	end
	
	describe "access controller" do
		describe "when not signed in" do
			it "should deny access" do
				get :dashboard
				response.should redirect_to signin_path
				
				get :details, :path_id => @path.id
				response.should redirect_to signin_path
			end		
		end
		
		describe "when signed in as a regular user" do
			before(:each) do
				test_sign_in(@user)
			end
			
			it "should deny access" do
				get :dashboard
				response.should redirect_to root_path
				
				get :details, :path_id => @path.id
				response.should redirect_to root_path
			end
		end
		
		describe "when signed in as company admin" do
			before(:each) do
				@user.user_roll = @admin_user_roll
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
	end

	describe "actions" do
		before(:each) do
			@user.user_roll = @admin_user_roll
			test_sign_in(@user)
		end
	
		describe "GET 'dashboard'" do
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
				
				describe "correctly and incorrectly answered question table" do
					before(:each) do
						@user.enroll!(@path)
						@task1 = FactoryGirl.create(:task, :section => @section)
						@task2 = FactoryGirl.create(:task, :section => @section)
						@task3 = FactoryGirl.create(:task, :section => @section)
						
						3.times do |n|
							FactoryGirl.create(:completed_task, :task => @task1, :user => @user, :status_id => 0)
						end
						
						2.times do |n|
							FactoryGirl.create(:completed_task, :task => @task2, :user => @user, :status_id => 0)
						end
						
						1.times do |n|
							FactoryGirl.create(:completed_task, :task => @task3, :user => @user, :status_id => 0)
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
					
					it "should display the rank of the most correctly answered questions" do
						get :details, :path_id => @path.id
						response.should have_selector("td#correct_rank_"+@task3.id.to_s, :content => "1")
						response.should have_selector("td#correct_rank_"+@task2.id.to_s, :content => "2")
						response.should have_selector("td#correct_rank_"+@task1.id.to_s, :content => "3")
					end
					
					it "should display the question of the most correctly answered questions" do
						get :details, :path_id => @path.id
						response.should have_selector("td#correct_question_"+@task3.id.to_s, :content => @task1.question)
						response.should have_selector("td#correct_question_"+@task2.id.to_s, :content => @task2.question)
						response.should have_selector("td#correct_question_"+@task1.id.to_s, :content => @task3.question)
					end
					
					it "should display the count of the most correctly answered questions" do
						get :details, :path_id => @path.id
						response.should have_selector("td#correct_count_"+@task3.id.to_s, :content => "1")
						response.should have_selector("td#correct_count_"+@task2.id.to_s, :content => "2")
						response.should have_selector("td#correct_count_"+@task1.id.to_s, :content => "3")
					end
				end
			end
		end
	end
end