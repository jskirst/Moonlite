require "spec_helper"

describe Task do
  it "should be delayed" do 
    path = FactoryGirl.create(:path)
    task1 = FactoryGirl.create(:task, path: path, question: "Take a look at this Task. You like it? You like this filthy little Task? 75")
    task1.delay.should == 2700
  end
end