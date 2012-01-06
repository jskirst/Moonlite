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
			@user = Factory(:user)
			@path = Factory(:path, :user => @user)
			@task = Factory(:task, :path => @path)
			test_sign_in(@user)
			@attr = { :user_id => @user.id, :task_id => @task.id, :answer => @task.correct_answer, :quiz_session => @quiz_session }
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
					end.should_not change(PointTransaction, :count)
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
					end.should change(PointTransaction, :count).by(1)
					pt = PointTransaction.find(:last, :conditions => ["task_id=? AND user_id=?", @task.id, @user.id])
					pt.status.should == 1
					pt.points.should == @task.points
					pt.user_id.should == @user.id
					pt.task_id.should == @task.id
				end
				
				it "should take you to the next question" do
					post :create, :completed_task => @attr
					flash[:success].should =~ /correct/i
				end
			end
			
			describe "with a skipped answer" do
				before(:each) do
					@attr = @attr.merge(:answer => nil)
				end
				
				it "should create a completed task with status 2 and quiz = " do
					lambda do
						post :create, :completed_task => @attr
					end.should change(CompletedTask, :count).by(1)
					cp = CompletedTask.find(:first, :conditions => ["task_id=? AND user_id=? AND status_id=2", @task.id, @user.id])
					cp.quiz_session.should == Time.parse(@quiz_session.utc.to_s)
				end
				
				it "should take you to the next question" do
					post :create, :completed_task => @attr
					flash[:notice].should =~ /skipped/i
				end
			end
		end
	end
end
	