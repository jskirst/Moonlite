require 'spec_helper'

describe Evaluation do
  before :each do
    init_metabright
    @group = FactoryGirl.create(:group, plan_type: Group::FREE_PLAN)
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
      3.times{ |i| FactoryGirl.create(:evaluation, group: @group) }
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
end