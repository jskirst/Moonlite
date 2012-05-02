require 'spec_helper'

describe SectionsController do
	render_views
	
	before(:each) do
		@company = FactoryGirl.create(:company)
		@regular_user_roll = FactoryGirl.create(:user_roll, :company => @company, :enable_administration => "f", :enable_user_creation => "f", :enable_collaboration => "f")
		@admin_user_roll = FactoryGirl.create(:user_roll, :company => @company)
		@user = FactoryGirl.create(:user, :company => @company, :user_roll => @regular_user_roll)
		
		@category = FactoryGirl.create(:category, :company => @company)
		@path = FactoryGirl.create(:path, :user => @user, :company => @user.company, :category => @categoy)
		@section = FactoryGirl.create(:section, :path => @path)
		@task1 = FactoryGirl.create(:task, :section => @section, :position => 1)
    @task2 = FactoryGirl.create(:task, :section => @section, :position => 2)
    @task3 = FactoryGirl.create(:task, :section => @section, :position => 3)
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
			it "should deny access to all functionality" do
				get :new, :path_id => @path.id
				response.should redirect_to signin_path
				
				post :create, :section => @attr
				response.should redirect_to signin_path
				
				get :show, :id => @section
				response.should redirect_to signin_path
				
				get :edit, :id => @section
				response.should redirect_to signin_path
				
				put :update, :id => @section, :section => @attr
				response.should redirect_to signin_path
				
				delete :destroy, :id => @section
				response.should redirect_to signin_path
				
				get :continue, :id => @section
				response.should redirect_to signin_path
			end
		end
		
		describe "when signed in as a regular user" do
			before(:each) do
				test_sign_in(@user)
			end
			
			it "should deny access to all editing functionality" do
				get :new, :path_id => @path.id
				response.should redirect_to root_path
				
				post :create, :section => @attr
				response.should redirect_to root_path
				
				get :edit, :id => @section
				response.should redirect_to root_path
				
				put :update, :id => @section, :section => @attr
				response.should redirect_to root_path
				
				delete :destroy, :id => @section
				response.should redirect_to root_path
			end
		
			it "should allow access to :show and :continue" do
				get :show, :id => @section
				response.should be_success
				
				get :continue, :id => @section
				response.should_not redirect_to root_path
				response.should be_success
			end
		end
		
		describe "when signed in as company admin" do
			before(:each) do
				@user.user_roll = @admin_user_roll
				test_sign_in(@user)
			end
			
			it "should allow access to all functionality" do
				get :show, :id => @section
				response.should be_success
				
				get :edit, :id => @section
				response.should be_success
				
				put :update, :id => @section, :section => @attr.merge(:path_id => nil)
				response.should redirect_to edit_section_path(Section.last, :m => "instructions")
				
				get :continue, :id => @section
				response.should_not redirect_to root_path
				response.should be_success
				
				delete :destroy, :id => @section
				response.should redirect_to edit_path_path(@path, :m => "sections")
				
				get :new, :path_id => @path.id
				response.should be_success
				
				post :create, :section => @attr
				response.should redirect_to edit_section_path(Section.last, :m => "instructions")
			end
		end
	end
	
	describe "actions" do
		before(:each) do
			@user.user_roll = @admin_user_roll
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
					response.should redirect_to edit_section_path(Section.last, :m => "instructions")
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
			it "should respond to tasks mode" do
				get :edit, :id => @section, :m => "tasks"
				response.should render_template("edit_tasks")
			end
			
			it "should respond to settings mode" do
				get :edit, :id => @section, :m => "settings"
				response.should render_template("edit_settings")
			end
			
						it "should respond to hidden_content mode" do
				get :edit, :id => @section, :m => "hidden_content"
				response.should render_template("edit_hidden_content")
			end
			
			it "should respond to randomize mode" do
				get :edit, :id => @section, :m => "randomize"
				response.should render_template("edit_tasks")
			end

			it "should have default mode of instructions" do
				get :edit, :id => @section
				response.should render_template("edit_instructions")
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
				
				it "should not allow section to be published without 1 task" do
					new_section = FactoryGirl.create(:section, :path => @path)
					put :update, :id => new_section, :section => {:name => "Good name", :instructions => "Good instructions", :is_published => 1}
					response.should be_succes
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
					response.should redirect_to edit_section_path(@section, :m => "instructions")
				end
				
				it "Should have a success message" do
					put :update, :id => @section, :section => @attr
					flash[:success].should =~ /updated/i
				end
			end
		end
		
		describe "GET :import_content" do
			before(:each) do
				@info_resource = FactoryGirl.create(:info_resource, :section_id => @section.id)
			end
			
			it "should respond successfully" do
				get :import_content, :id => @section, :previous => @info_resource.id
				response.should be_success
			end
		end
		
		describe "GET :preview_content" do
			before(:each) do
				@file = fixture_file_upload('files/test_pic.jpg', 'image/jpg')
			end
			
			it "should be successful" do
				put :preview_content, :id => @section, :section => {:file => @file}
				response.should be_success
			end
			
			it "should create info_resource" do
				lambda do
					put :preview_content, :id => @section, :section => {:file => @file}
				end.should change(InfoResource, :count).by(1)
			end
		end
		
		describe "GET :research" do
			it "should clear instructions on clear mode" do
				get :research, :id => @section, :m => "clear"
				@section.reload
				@section.instructions.should == nil
			end
			
			it "should respond to create mode" do
				get :research, :id => @section, :m => "create", :topics => "vitamin d, vitamin c"
				response.should be_success
			end
			
			it "should respond to topics mode" do
				get :research, :id => @section, :m => "topics"
				response.should render_template("research_settings")
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
				FactoryGirl.create(:completed_task, :task => @task1, :user => @user)
				get :continue, :id => @section
				response.should have_selector("p", :content => @task2.question)
			end
			
			it "should display the next lowest positioned task that is not yet completed (3/3)" do
				FactoryGirl.create(:completed_task, :task => @task1, :user => @user)
				FactoryGirl.create(:completed_task, :task => @task2, :user => @user)
				get :continue, :id => @section
				response.should have_selector("p", :content => @task3.question)
			end
			
			it "should render results when the max questions are reached." do
				FactoryGirl.create(:completed_task, :task => @task1, :user => @user)
				FactoryGirl.create(:completed_task, :task => @task2, :user => @user)
				FactoryGirl.create(:completed_task, :task => @task3, :user => @user)
				get :continue, :id => @section
				response.should render_template("results")
			end
			
			describe "users score on results screen" do
				before(:each) do
					@quiz_session = DateTime.now
				end
			
				it "should be 3/6 when all answers are incorrect and then answered correctly" do
					@completed_task1 = FactoryGirl.create(:completed_task, :task => @task1, :user => @user, :quiz_session => @quiz_session, :status_id => 0)
					@completed_task2 = FactoryGirl.create(:completed_task, :task => @task2, :user => @user, :quiz_session => @quiz_session, :status_id => 0)
					@completed_task3 = FactoryGirl.create(:completed_task, :task => @task3, :user => @user, :quiz_session => @quiz_session, :status_id => 0)
          @completed_task1 = FactoryGirl.create(:completed_task, :task => @task1, :user => @user, :quiz_session => @quiz_session, :status_id => 1)
					@completed_task2 = FactoryGirl.create(:completed_task, :task => @task2, :user => @user, :quiz_session => @quiz_session, :status_id => 1)
					@completed_task3 = FactoryGirl.create(:completed_task, :task => @task3, :user => @user, :quiz_session => @quiz_session, :status_id => 1)
					get :continue, :id => @section
					response.should have_selector("h4", :content => "3/6")
				end
				
				it "should be 3/3 when all answers are correct" do
					@completed_task1 = FactoryGirl.create(:completed_task, :task => @task1, :user => @user, :quiz_session => @quiz_session, :status_id => 1)
					@completed_task2 = FactoryGirl.create(:completed_task, :task => @task2, :user => @user, :quiz_session => @quiz_session, :status_id => 1)
					@completed_task2 = FactoryGirl.create(:completed_task, :task => @task3, :user => @user, :quiz_session => @quiz_session, :status_id => 1)
					get :continue, :id => @section
					response.should have_selector("h4", :content => "3/3")
				end
			end
		end
	end
end
	