require "spec_helper"

describe Path do
  before :each do
    @path = FactoryGirl.create(:path)
    section = FactoryGirl.create(:section, path: @path)
    task1 = FactoryGirl.create(:task, section: section, path: @path, difficulty: Task::EASY)
    task1 = FactoryGirl.create(:task, section: section, path: @path, difficulty: Task::MEDIUM)
    task1 = FactoryGirl.create(:task, section: section, path: @path, difficulty: Task::HARD)
    @path.tasks.size.should == 3
    @difficulty = (Task::EASY + Task::MEDIUM + Task::HARD) / 3 # (1 + 1.25 + 1.5) / 3 = 1.25
    @difficulty.should == 1.25
  end
  
  describe ".average_difficulty" do
    it "should return numerical average difficulty of all tasks" do
      @path.average_difficulty.should == @difficulty
    end
  end
  
  describe ".describe_average_difficulty" do
    it "should humanized average difficulty of all tasks" do
      @path.describe_average_difficulty.should == "Medium"
    end
  end
end