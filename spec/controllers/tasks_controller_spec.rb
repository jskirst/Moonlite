require 'spec_helper'

describe TasksController do
	render_views
	
	before(:each) do
		@user = Factory(:user)
		@path = Factory(:path, :user => @user, :company => @user.company)
		@section = Factory(:section, :path => @path)
		@task = Factory(:task, :section => @section)
	
		@attr = {
			:question => "Replacement question", 
			:answer1 => "Replacement answer", 
			:answer2 => "Replacement answer",
			:answer3 => "Replacement answer",
			:answer4 => "Replacement answer",
			:resource => "fake", 
			:points => 5,
			:correct_answer => 1,
			:section_id => 1
		}
	end
	
	describe "access controller" do
		describe "when not signed in" do
			it "should deny access to 'new'" do
				get :new, :section_id => @section.id
				response.should redirect_to signin_path
			end
		
			it "should deny access to 'create'" do
				post :create, :task => @attr
				response.should redirect_to signin_path
			end
			
			it "should deny access to 'show'" do
				get :show, :id => @task
				response.should redirect_to signin_path
			end
			
			it "should deny access to 'edit'" do
				get :edit, :id => @task
				response.should redirect_to signin_path
			end			
			
			it "should deny access to 'update'" do
				put :update, :id => @task, :task => @attr
				response.should redirect_to signin_path
			end
			
			it "should deny access to 'destroy'" do
				delete :destroy, :id => @task
				response.should redirect_to signin_path
			end
		end
    
		describe "when signed in as a regular user" do
			before(:each) do
				test_sign_in(@user)
			end
			
			it "should deny access to 'new'" do
				get :new, :section_id => @section.id
				response.should redirect_to root_path
			end
		
			it "should deny access to 'create'" do
				post :create, :task => @attr
				response.should redirect_to root_path
			end
			
			it "should deny access to 'show'" do
				get :show, :id => @task
				response.should redirect_to root_path
			end
			
			it "should deny access to 'edit'" do
				get :edit, :id => @task
				response.should redirect_to root_path
			end			
			
			it "should deny access to 'update'" do
				put :update, :id => @task, :task => @attr
				response.should redirect_to root_path
			end
			
			it "should deny access to 'destroy'" do
				delete :destroy, :id => @task
				response.should redirect_to root_path
			end
		end
		
		describe "when signed in as company admin" do
			before(:each) do
				@user.set_company_admin(true)
				test_sign_in(@user)
			end
			
			it "should allow access to 'new'" do
				get :new, :section_id => @section.id
				response.should be_success
			end
		
			it "should allow access to 'create' and redirect to section" do
				post :create, :task => @attr
				response.should redirect_to edit_section_path(@section, :m => "tasks")
			end
			
			it "should allow access to 'show'" do
				get :show, :id => @task
				response.should be_success
			end
			
			it "should allow access to 'edit'" do
				get :edit, :id => @task
				response.should be_success
			end
			
			it "should allow access to 'update' and redirect to updated task" do
				put :update, :id => @task, :task => @attr.delete("section_id")
				response.should redirect_to edit_section_path(:id => @task.section.id, :m => "tasks")
			end
			
			it "should allow access to 'destroy'" do
				delete :destroy, :id => @task
				response.should redirect_to edit_section_path(:id => @task.section.id, :m => "tasks")
			end
		end
	end
	
	describe "actions" do
		before(:each) do
			@user.set_company_admin(true)
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
					flash[:success].should =~ /task created/i
				end
			end
		end
		
		describe "Get 'show'" do
			it "should find the right task" do
				get :show, :id => @task
				assigns(:task).should == @task
			end
			
			it "should have the section's name in the title" do
				get :show, :id => @task
				response.should have_selector("title", :content => @section.name)
			end
			
			it "should display the question" do
				get :show, :id => @task
				response.should have_selector("p", :content => @task.question)
			end
			
			it "should display the answer" do
				get :show, :id => @task
				response.should have_selector("li", :content => @task.answer1)
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
	