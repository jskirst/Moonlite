require 'spec_helper'

describe EvaluationPath do
  describe ".select_tasks" do
    it "should run select_tasks before_create" do
      group = FactoryGirl.create(:group_with_evaluation)
      group.evaluations.first.should_not be_nil
      ep = group.evaluations.first.evaluation_paths.first

      core_tasks = ep.path.tasks.where(answer_type: Task::MULTIPLE).first(EvaluationPath::CORE_LIMIT)
      core_tasks.size.should > 0
      creative_tasks = ep.path.tasks.where(answer_type: Task::CREATIVE, answer_sub_type: Task::TEXT).first(EvaluationPath::CORE_LIMIT)
      creative_tasks.size.should > 0
      ep.task_ids.split(",").should == (core_tasks.collect(&:id) + creative_tasks.collect(&:id)).map(&:to_s)
    end
  end
end