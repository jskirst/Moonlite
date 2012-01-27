require 'spec_helper'

describe CompletedTasksController do
	render_views
	
	before(:each) do
		@quiz_session = DateTime.now
	end
	
	describe "access controller" do	
		it "should deny access to 'create'" do
			post :create
			response.should redirect_to(signin_path)
		end
	end
	
	describe "POST 'create'" do
		before(:each) do
			@password = "current_password"
			@user = Factory(:user, :password => @password, :password_confirmation => @password)
			@user.set_company_admin(true)
			@path = Factory(:path, :user => @user)
			@section = Factory(:section, :path => @path)
			@task = Factory(:task, :section => @section)
			test_sign_in(@user)
			@attr = { :user_id => @user.id, :task_id => @task.id, :answer => @task.correct_answer, :quiz_session => @quiz_session }
		end
		
		describe "with a bad task argument" do
			it "should redirect to root_path" do
				post :create, :completed_task => @attr.delete("task_id")
				response.should redirect_to root_path
			end
		end
		
		describe "as an unenrolled user" do
			it "should deny access" do
				post :create, :completed_task => @attr
				response.should redirect_to(root_path)
			end
		end
		
		describe "as an enrolled user" do
			before(:each) do
				@user.enroll!(@path)
			end
			
			describe "with an incorrect answer" do
				before(:each) do
					@attr = @attr.merge(:answer => 0)
				end
			
				it "should create a completed task with status 0" do
					lambda do
						post :create, :completed_task => @attr  
					end.should change(CompletedTask, :count).by(1)
					cp = CompletedTask.find(:first, :conditions => ["task_id=? AND user_id=? AND status_id=0", @task.id, @user.id])
					cp.quiz_session.should == Time.parse(@quiz_session.utc.to_s)
				end
				
				it "should not create a point transaction" do
					lambda do
						post :create, :completed_task => @attr  
					end.should_not change(UserTransaction, :count)
				end
				
				it "should not create a user achievement" do
					lambda do
						post :create, :completed_task => @attr  
					end.should_not change(UserAchievement, :count)
				end
				
				it "should take you to the next question" do
					post :create, :completed_task => @attr
					flash[:error].should =~ /incorrect/i
				end
			end
			
			describe "with a correct answer" do
				it "should create a completed task with status 1" do
					lambda do
						post :create, :completed_task => @attr
					end.should change(CompletedTask, :count).by(1)
					cp = CompletedTask.find(:first, :conditions => ["task_id=? AND user_id=? AND status_id=1", @task.id, @user.id])
					cp.quiz_session.should == Time.parse(@quiz_session.utc.to_s)
				end
				
				it "should create a point transaction with status 1 and same attributes as the completed task" do
					lambda do
						post :create, :completed_task => @attr
					end.should change(UserTransaction, :count).by(1)
					pt = UserTransaction.find(:last, :conditions => ["task_id=? AND user_id=?", @task.id, @user.id])
					pt.status.should == 1
					pt.amount.should == @task.points
					pt.user_id.should == @user.id
					pt.task_id.should == @task.id
				end
				
				it "should take you to the next question" do
					post :create, :completed_task => @attr
					flash[:success].should =~ /correct/i
				end
				
				describe "with an invalid achievement" do
					before(:each) do
						@achievement = Factory(:achievement, :path => @path, :criteria => "abcd")
					end
					
					it "should still create a completed task with status 1" do
						lambda do
							post :create, :completed_task => @attr
						end.should change(CompletedTask, :count).by(1)
						cp = CompletedTask.find(:first, :conditions => ["task_id=? AND user_id=? AND status_id=1", @task.id, @user.id])
						cp.should_not be_nil
					end
					
					it "should still take you to the next question" do
						post :create, :completed_task => @attr
						flash[:success].should =~ /correct/i
					end
					
					it "should not award an achievement" do
						lambda do
							post :create, :completed_task => @attr
						end.should_not change(UserAchievement, :count)
					end
				end
				
				describe "with valid achievements" do
					before(:each) do
						@old_task1 = Factory(:task, :path => @path)
						@old_task2 = Factory(:task, :path => @path)
					end
					
					describe "for completing all tasks for the path" do
						before(:each) do
							Factory(:completed_task, :task => @old_task1, :user => @user)
							Factory(:completed_task, :task => @old_task2, :user => @user)
							@achievement = Factory(:achievement, :path => @path, :criteria => "all")
						end
					
						it "should award the achievement" do
							lambda do
								post :create, :completed_task => @attr
							end.should change(UserAchievement, :count).by(1)
							ua = UserAchievement.find(:all, :conditions => ["achievement_id = ? and user_id = ?", @achievement.id, @user.id])
							ua.should_not be_empty
						end
						
						it "should not change the user's encrypted password" 
						#TODO: automation isn't catching this. See user.rb:128
					end
					
					describe "for completing tasks specified in achievement criteria" do
						before(:each) do
							Factory(:completed_task, :task => @old_task1, :user => @user)
							@achievement = Factory(:achievement, :path => @path, :criteria => @old_task1.id.to_s + "," + @task.id.to_s)
						end
						
						it "should award the achievement" do
							lambda do
								post :create, :completed_task => @attr
							end.should change(UserAchievement, :count).by(1)
							ua = UserAchievement.find(:all, :conditions => ["achievement_id = ? and user_id = ?", @achievement.id, @user.id])
							ua.should_not be_empty
						end
					end
				end
			end
		end
	end
end
	