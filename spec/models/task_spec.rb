require "spec_helper"

describe Task do
  describe ".delayed" do
    it "should return delay in milliseconds based on length of question" do
      path = FactoryGirl.create(:path)
      section = FactoryGirl.create(:section, path: path)
      task1 = FactoryGirl.create(:task, section: section, path: path, question: "Take a look at this Task. You like it? You like this filthy little Task? 75")
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

  describe ".deep_copy" do
    path1 = FactoryGirl.create(:path_with_tasks)

    path2 = FactoryGirl.create(:path)
    section2 = FactoryGirl.create(:section, path: path2)
    
    task1 = path1.tasks.where(answer_type: Task::MULTIPLE).first
    task2 = task1.deep_copy(path2)

    task1.should_not == task2
    task2.path_id.should == path2.id
    task2.answers.size.should > 0
  end
end