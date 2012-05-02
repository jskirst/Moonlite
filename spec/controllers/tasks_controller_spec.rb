require 'spec_helper'

describe TasksController do
	render_views
	
	before(:each) do
		@company = FactoryGirl.create(:company)
		@regular_user_roll = FactoryGirl.create(:user_roll, :company => @company, :enable_administration => "f", :enable_user_creation => "f", :enable_collaboration => "f")
		@admin_user_roll = FactoryGirl.create(:user_roll, :company => @company)
		@user = FactoryGirl.create(:user, :company => @company, :user_roll => @regular_user_roll)
		
		@category = FactoryGirl.create(:category, :company => @company)
		@path = FactoryGirl.create(:path, :user => @user, :company => @user.company, :category => @categoy)
		@section = FactoryGirl.create(:section, :path => @path)
		@task = FactoryGirl.create(:task, :section => @section)
	
		@attr = {
			:question => "Replacement question", 
			:answer1 => "Replacement answer", 
			:answer2 => "Replacement answer",
			:correct_answer => 1,
			:section_id => 1
		}
	end
	
	describe "access controller" do
		describe "when not signed in" do
			it "should deny access to all functionality" do
				get :new, :section_id => @section.id
				response.should redirect_to signin_path
				post :create, :task => @attr
				response.should redirect_to signin_path
				get :edit, :id => @task
				response.should redirect_to signin_path
				put :update, :id => @task, :task => @attr
				response.should redirect_to signin_path
				delete :destroy, :id => @task
				response.should redirect_to signin_path
			end
		end
    
		describe "when signed in as a regular user" do
			before(:each) do
				test_sign_in(@user)
			end
			
			it "should deny access to :new, :create, :show, :edit, :update, :destroy" do
				get :new, :section_id => @section.id
				response.should redirect_to root_path
				post :create, :task => @attr
				response.should redirect_to root_path
				get :edit, :id => @task
				response.should redirect_to root_path
				put :update, :id => @task, :task => @attr
				response.should redirect_to root_path
				delete :destroy, :id => @task
				response.should redirect_to root_path
			end
		end
		
		describe "when signed in as company admin" do
			before(:each) do
				@user.user_roll = @admin_user_roll
				test_sign_in(@user)
			end
			
			it "should allow access to all functionality" do
				get :new, :section_id => @section.id
				response.should be_success
				post :create, :task => @attr
				response.should redirect_to edit_section_path(@section, :m => "tasks")
				get :edit, :id => @task
				response.should be_success
				put :update, :id => @task, :task => @attr
				response.should redirect_to edit_section_path(:id => @task.section.id, :m => "tasks")
				delete :destroy, :id => @task
				response.should redirect_to edit_section_path(:id => @task.section.id, :m => "tasks")
			end
		end
	end
	
	describe "actions" do
		before(:each) do
			@user.user_roll = @admin_user_roll
			test_sign_in(@user)
		end
		
		describe "GET 'new'" do
			it "should have right title" do
				get :new, :section_id => @section.id
				response.should have_selector("title", :content => "New")
			end
		end
		
		describe "POST 'create'" do
			describe "failure" do
				before(:each) do
					@attr = @attr.merge(:question => "", :answer1 => "")
				end
			
				it "should not create a task" do
					lambda do
						post :create, :task => @attr  
					end.should_not change(Task, :count)
				end
				
				it "should take you back to the new task page" do
					post :create, :task => @attr
					response.should render_template("tasks/task_form")
				end
			end
			
			describe "success" do
				it "should create a task" do
					lambda do
						post :create, :task => @attr
					end.should change(Task, :count).by(1)		
				end
				
				it "should redirect to the path page" do
					post :create, :task => @attr
					response.should redirect_to edit_section_path(@section, :m => "tasks")
				end
				
				it "should have a flash message" do
					post :create, :task => @attr
					flash[:success].should =~ /question created/i
				end
			end
		end
		
		describe "GET 'edit'" do
			it "should be successful" do
				get :edit, :id => @task
				response.should be_success
			end

			it "should have right title" do
				get :edit, :id => @task
				response.should have_selector("title", :content => "Edit")
			end
		end
		
		describe "PUT 'update'" do
			describe "Failure" do
				before(:each) do
					@attr = @attr.merge(:question => "", :answer1 => "")
				end
				
				it "should render the edit page" do
					put :update, :id => @task, :task => @attr
					response.should render_template("tasks/task_form")
				end
				
				it "should have the right title" do
					put :update, :id => @task, :task => @attr
					response.should have_selector("title", :content => "Edit")
				end
				
				it "should have an error message" do
					put :update, :id => @task, :task => @attr
					response.should have_selector("p", :content => "The were problems with the following fields")
				end
			end
			
			describe "Success" do
				before(:each) do
					@attr = @attr.merge(:question => "Changed question", :answer1 => "Changed answer")
				end
			
				it "should change task successfully" do
					put :update, :id => @task, :task => @attr
					@task.reload
					@task.question.should == @attr[:question]
					@task.answer1.should == @attr[:answer1]
				end
				
				it "should redirect to task page" do
					put :update, :id => @task, :task => @attr
					response.should redirect_to edit_section_path(:id => @task.section.id, :m => "tasks")
				end
				
				it "should have a success message" do
					put :update, :id => @task, :task => @attr
					flash[:success].should =~ /updated/i
				end
			end
		end
		
		describe "DELETE 'destroy'" do			
			it "should destroy the task" do
				lambda do
					delete :destroy, :id => @task
				end.should change(Task, :count).by(-1)
			end
			
			it "should redirect to index page" do
				delete :destroy, :id => @task
        response.should redirect_to edit_section_path(:id => @task.section.id, :m => "tasks")
			end
		end
	end
end
	