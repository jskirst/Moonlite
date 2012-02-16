require 'spec_helper'

describe SectionsController do
	render_views
	
	before(:each) do
		@user = Factory(:user)
		@path = Factory(:path, :user => @user, :company => @user.company, :is_published => true)
		@section = Factory(:section, :path => @path, :position => 0, :is_published => true)
		@task1 = Factory(:task, :section => @section)
    @task2 = Factory(:task, :section => @section)
    @task3 = Factory(:task, :section => @section)
		@user.enroll!(@path)
		
		@attr = {
			:name => "Replacement description", 
			:instructions => "http://www.testlink.com",
			:path_id => @path.id,
			:position => 1
		}
	end
	
	describe "access controller" do
		describe "when not signed in" do
			it "should deny access to 'new'" do
				get :new, :path_id => @path.id
				response.should redirect_to signin_path
			end
		
			it "should deny access to 'create'" do
				post :create, :section => @attr
				response.should redirect_to signin_path
			end
			
			it "should deny access to 'show'" do
				get :show, :id => @section
				response.should redirect_to signin_path
			end
			
			it "should deny access to 'edit'" do
				get :edit, :id => @section
				response.should redirect_to signin_path
			end			
			
			it "should deny access to 'update'" do
				put :update, :id => @section, :section => @attr
				response.should redirect_to signin_path
			end

			it "should deny access to 'destroy'" do
				delete :destroy, :id => @section
				response.should redirect_to signin_path
			end
			
			it "should deny access to 'continue'" do
				get :continue, :id => @section
				response.should redirect_to signin_path
			end
		end
		
		describe "when signed in as a regular user" do
			before(:each) do
				test_sign_in(@user)
			end
			
			it "should deny access to 'new'" do
				get :new, :path_id => @path.id
				response.should redirect_to root_path
			end
		
			it "should deny access to 'create'" do
				post :create, :section => @attr
				response.should redirect_to root_path
			end
			
			it "should allow access to 'show'" do
				get :show, :id => @section
				response.should be_success
			end
			
			it "should deny access to 'edit'" do
				get :edit, :id => @section
				response.should redirect_to root_path
			end			
			
			it "should deny access to 'update'" do
				put :update, :id => @section, :section => @attr
				response.should redirect_to root_path
			end
			
			it "should deny access to 'destroy'" do
				delete :destroy, :id => @section
				response.should redirect_to root_path
			end
			
			it "should allow access to 'continue'" do
				get :continue, :id => @section
				response.should_not redirect_to root_path
				response.should be_success
			end
		end
		
		describe "when signed in as company admin" do
			before(:each) do
				@user.set_company_admin(true)
				test_sign_in(@user)
			end
			
			it "should allow access to 'new'" do
				get :new, :path_id => @path.id
				response.should be_success
			end
		
			it "should allow access to 'create'" do
				post :create, :section => @attr
				response.should redirect_to edit_path_path(@path, :m => "sections")
			end
			
			it "should allow access to 'show'" do
				get :show, :id => @section
				response.should be_success
			end
			
			it "should allow access to 'edit'" do
				get :edit, :id => @section
				response.should be_success
			end
			
			it "should allow access to 'update'" do
				put :update, :id => @section, :section => @attr.delete("path_id")
				response.should render_template "edit"
			end
			
			it "should allow access to 'destroy'" do
				delete :destroy, :id => @section
				response.should redirect_to edit_path_path(@path, :m => "sections")
			end
			
			it "should allow access to 'continue'" do
				get :continue, :id => @section
				response.should_not redirect_to root_path
				response.should be_success
			end
		end
	end
	
	describe "actions" do
		before(:each) do
			@user.set_company_admin(true)
			test_sign_in(@user)
		end
		
		describe "GET 'new'" do
			it "should be successful" do
				get :new, :path_id => @path.id
				response.should be_success
			end

			it "should have right title" do
				get :new, :path_id => @path.id
				response.should have_selector("title", :content => "New")
			end
		end
		
		describe "POST 'create'" do
			describe "failure" do
				before(:each) do
					@attr = @attr.merge(:name => "", :instructions => "", :position => "", :path_id => @path.id)
				end
			
				it "should not create a section" do
					lambda do
						post :create, :section => @attr
					end.should_not change(Section, :count)
				end
				
				it "should take you back to the new section page" do
					post :create, :section => @attr
					response.should render_template("new")
				end
			end
			
			describe "success" do
				it "should create a new Section" do
					lambda do
						post :create, :section => @attr
					end.should change(Section, :count).by(1)		
				end
				
				it "should redirect to the section show page" do
					post :create, :section => @attr
					response.should redirect_to edit_path_path(@path, :m => "sections")
				end
				
				it "should have a flash message" do
					post :create, :section => @attr
					flash[:success].should =~ /section created/i
				end
			end
		end
		
		describe "Get 'show'" do
			it "should be successful" do
				get :show, :id => @section
				response.should be_success
			end
			
			it "Should find the right section" do
				get :show, :id => @section
				assigns(:section).should == @section
			end
			
			it "Should have the section's name in the title" do
				get :show, :id => @section
				response.should have_selector("title", :content => @section.name)
			end
		end
		
		describe "GET 'edit'" do
			it "should be successful" do
				get :edit, :id => @section
				response.should be_success
			end

			it "should have right title" do
				get :edit, :id => @section
				response.should have_selector("title", :content => "Edit")
			end
		end
		
		describe "PUT 'update'" do
			describe "Failure" do
				before(:each) do
					@attr = @attr.merge(:name => "", :instructions => "")
				end
				
				it "should render the edit page" do
					put :update, :id => @section, :section => @attr
					response.should render_template("edit")
				end
				
				it "should have the right title" do
					put :update, :id => @section, :section => @attr
					response.should have_selector("title", :content => "Edit")
				end
				
				it "should have an error message" do
					put :update, :id => @section, :section => @attr
					response.should have_selector("p", :content => "The were problems with the following fields")
				end
			end
			
			describe "Success" do
				it "Should change section successfully" do
					put :update, :id => @section, :section => @attr
					@section.reload
					@section.name.should == @attr[:name]
					@section.instructions.should == @attr[:instructions]
				end
				
				it "Should redirect to section page" do
					put :update, :id => @section, :section => @attr
					response.should render_template "edit"
				end
				
				it "Should have a success message" do
					put :update, :id => @section, :section => @attr
					flash[:success].should =~ /updated/i
				end
			end
		end
		
		describe "DELETE 'destroy'" do
			it "should destroy the section" do
				lambda do
					delete :destroy, :id => @section
				end.should change(Section, :count).by(-1)
			end
			
			it "should redirect to the section's path" do
				delete :destroy, :id => @section
				response.should redirect_to edit_path_path(@path, :m => "sections")
			end
		end
		
		describe "GET 'continue'" do
      it "should find the right section" do
				get :continue, :id => @section
				assigns(:section).should == @section
			end
			
			it "should display the lowest positioned task when no tasks" do
				get :continue, :id => @section
				response.should have_selector("p", :content => @task1.question)
			end
			
			it "should display the next lowest positioned task that is not yet completed (2/3)" do
				Factory(:completed_task, :task => @task1, :user => @user)
				get :continue, :id => @section
				response.should have_selector("p", :content => @task2.question)
			end
			
			it "should display the next lowest positioned task that is not yet completed (3/3)" do
				Factory(:completed_task, :task => @task1, :user => @user)
				Factory(:completed_task, :task => @task2, :user => @user)
				get :continue, :id => @section
				response.should have_selector("p", :content => @task3.question)
			end
			
			it "should render results when the max questions are reached." do
				Factory(:completed_task, :task => @task1, :user => @user)
				Factory(:completed_task, :task => @task2, :user => @user)
				Factory(:completed_task, :task => @task3, :user => @user)
				get :continue, :id => @section
				response.should render_template("results")
			end
			
			describe "users score on results screen" do
				before(:each) do
					@quiz_session = DateTime.now
				end
			
				it "should be 3/6 when all answers are incorrect and then answered correctly" do
					@completed_task1 = Factory(:completed_task, :task => @task1, :user => @user, :quiz_session => @quiz_session, :status_id => 0)
					@completed_task2 = Factory(:completed_task, :task => @task2, :user => @user, :quiz_session => @quiz_session, :status_id => 0)
					@completed_task3 = Factory(:completed_task, :task => @task3, :user => @user, :quiz_session => @quiz_session, :status_id => 0)
          @completed_task1 = Factory(:completed_task, :task => @task1, :user => @user, :quiz_session => @quiz_session, :status_id => 1)
					@completed_task2 = Factory(:completed_task, :task => @task2, :user => @user, :quiz_session => @quiz_session, :status_id => 1)
					@completed_task3 = Factory(:completed_task, :task => @task3, :user => @user, :quiz_session => @quiz_session, :status_id => 1)
					get :continue, :id => @section
					response.should have_selector("h4", :content => "3/6")
				end
				
				it "should be 3/3 when all answers are correct" do
					@completed_task1 = Factory(:completed_task, :task => @task1, :user => @user, :quiz_session => @quiz_session, :status_id => 1)
					@completed_task2 = Factory(:completed_task, :task => @task2, :user => @user, :quiz_session => @quiz_session, :status_id => 1)
					@completed_task2 = Factory(:completed_task, :task => @task3, :user => @user, :quiz_session => @quiz_session, :status_id => 1)
					get :continue, :id => @section
					response.should have_selector("h4", :content => "3/3")
				end
			end
		end
	end
end
	