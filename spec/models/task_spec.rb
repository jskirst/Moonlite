require "spec_helper"

describe Task do
  describe ".delayed" do
    it "should return delay in milliseconds based on length of question" do
      path = FactoryGirl.create(:path)
      task1 = FactoryGirl.create(:task, path: path, question: "Take a look at this Task. You like it? You like this filthy little Task? 75")
      task1.delay.should == 2700
    end
  end
  
  describe "self.describe_difficulty" do
    it "should return easy below 1.25, medium below 1.5, hard below 1.75, then expert" do
      Task.describe_difficulty(1).should == "Easy"
      Task.describe_difficulty(1.24).should == "Easy"
      Task.describe_difficulty(1.25).should == "Medium"
      Task.describe_difficulty(1.49).should == "Medium"
      Task.describe_difficulty(1.5).should == "Hard"
      Task.describe_difficulty(1.74).should == "Hard"
      Task.describe_difficulty(1.75).should == "Expert"
      Task.describe_difficulty(1.99).should == "Expert"
    end
  end
end