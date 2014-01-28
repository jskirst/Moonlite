require 'spec_helper'

describe Evaluation do
  before :each do
    @group = FactoryGirl.create(:group_with_evaluation, plan_type: Group::FREE_PLAN)
    @group.reload
    @group.evaluations.first.should_not be_nil
    @creator = @group.users.first
  end

  describe "creation" do
    it "should succeed with the minimum required fields" do
      @eval = Evaluation.create! do |e|
        e.user = @creator
        e.group = @group
        e.company = "My Company"
        e.title = "My Open Position"
        e.selected_paths = { Path.first.id => true }
      end
    end

    it "should not succeed if group is FREE_PLAN and has 3 evaluations" do
      2.times{ |i| FactoryGirl.create(:evaluation, group: @group) }
      @group.reload
      @group.evaluations.size.should == 3
      @group.available_evaluations?.should be_false
      @eval = Evaluation.create do |e|
        e.user = @creator
        e.group = @group
        e.company = "My Company"
        e.title = "My Open Position"
        e.selected_paths = { Path.first.id => true }
      end
      @eval.should_not be_valid
    end
  end

  describe "arena progression" do
    before :each do
      @eval = @group.evaluations.first
      @ep = @eval.evaluation_paths.first 
      @path = @eval.paths.first
      @core_tasks = @ep.path.tasks.where(answer_type: Task::MULTIPLE).order("id ASC").to_a
      @core_tasks.size.should > 0
      @creative_tasks = @ep.path.tasks.where(answer_type: Task::CREATIVE, answer_sub_type: Task::TEXT).order("id ASC").to_a
      @creative_tasks.size.should > 0
    end

    describe ".task_of_type" do
      it "should return all core tasks" do
        @eval.tasks_of_type(@path, [Task::MULTIPLE, Task::EXACT]).should == @core_tasks
      end

      it "should return all core tasks" do
        @eval.tasks_of_type(@path, [Task::CREATIVE]).should == @creative_tasks
      end
    end

    describe ".next_task_of_type" do
      it "should return all tasks" do
        user = FactoryGirl.create(:user)
        @eval.next_task_of_type(user, @path, [Task::MULTIPLE, Task::EXACT]).should == @core_tasks.first
      end

      it "should return all except for completed task" do
        user = FactoryGirl.create(:user)
        user.completed_tasks.create! do |ct|
          ct.task_id = @core_tasks.first.id
          ct.status_id = Answer::CORRECT
          ct.answer = "Blah"
          ct.enrollment_id = user.enroll!(@path).id
        end
        @eval.next_task_of_type(user, @path, [Task::MULTIPLE, Task::EXACT]).should == @core_tasks[1]
      end
    end

    describe ".next_task" do
      before :each do
        @user = FactoryGirl.create(:user)
        @e = @user.enroll!(@path)
      end

      it "should return first core task" do
        resp = @eval.next_task(@user, @path)
        resp[:next_task].should == @core_tasks.first
      end

      it "should return second core task if first is completed" do
        @user.completed_tasks.create! do |ct|
          ct.task_id = @core_tasks.first.id
          ct.status_id = Answer::CORRECT
          ct.answer = "Blah"
          ct.enrollment_id = @e.id
        end
        resp = @eval.next_task(@user, @path)
        resp[:next_task].should == @core_tasks[1]
      end

      describe "for creative tasks" do
        before :each do 
          @user = FactoryGirl.create(:user)
          @core_tasks.each do |t|
            @user.completed_tasks.create! do |ct|
              ct.task_id = t.id
              ct.status_id = Answer::CORRECT
              ct.answer = "Blah"
              ct.enrollment_id = @e.id
            end
          end
        end
        
        it "should return first creative question if core tasks are completed" do
          resp = @eval.next_task(@user, @path)
          resp[:next_task].should == @creative_tasks.first
        end

        it "should return nil for next task if all tasks finished" do
          @creative_tasks.each do |t|
            @user.completed_tasks.create! do |ct|
              ct.task_id = t.id
              ct.status_id = Answer::CORRECT
              ct.answer = "Blah"
              ct.enrollment_id = @e.id
            end
          end
          resp = @eval.next_task(@user, @path).should be_nil
        end
      end
    end
  end
end