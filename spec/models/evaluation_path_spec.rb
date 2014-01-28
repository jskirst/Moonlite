require 'spec_helper'

describe EvaluationPath do
  before :each do
    @group = FactoryGirl.create(:group_with_evaluation)
    @group.evaluations.first.should_not be_nil
    @eval = @group.evaluations.first
    @ep = @eval.evaluation_paths.first
    @path = @ep.path
  end

  describe ".tasks_with_difficulty" do
    it "should return tasks between lower bound and upper bound" do
      @ep.tasks_with_difficulty(@path.tasks.where(answer_type: Task::MULTIPLE), Task::EXPERT, 2.0).count.should == 3
      @ep.tasks_with_difficulty(@path.tasks.where(answer_type: Task::MULTIPLE), Task::HARD, Task::EXPERT).count.should == 3
      @ep.tasks_with_difficulty(@path.tasks.where(answer_type: Task::MULTIPLE), Task::MEDIUM, Task::HARD).count.should == 3
      @ep.tasks_with_difficulty(@path.tasks.where(answer_type: Task::MULTIPLE), 0, Task::MEDIUM).count.should == 3
    end
  end


  describe ".select_tasks" do
    it "should run select_tasks before_create" do
      core_tasks = @path.tasks.where(answer_type: Task::MULTIPLE)
      core_tasks.size.should > 0
      creative_tasks = @path.tasks.where(answer_type: Task::CREATIVE, answer_sub_type: Task::TEXT)
      creative_tasks.size.should > 0
      @ep.task_ids.split(",").should == (1..15).to_a.map(&:to_s)
    end
  end
end