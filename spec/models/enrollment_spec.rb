require 'spec_helper'

describe Enrollment do
  before :each do
    init_metabright
  end
  
  describe ".metascore" do
    before :each do
      @path = FactoryGirl.create(:path)
      @section = FactoryGirl.create(:section, path: @path)
      @multipliers = [1,2,3,4]
      @easy = 0
      @medium = 1
      @hard = 2
      @expert = 3

      @user = FactoryGirl.create(:user)
    end
    
    it "easy difficulty" do
      3.times { FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EASY) }
      complete_tasks(@path.tasks.where(difficulty: Task::EASY), @user, 100)
      enrollment = @user.enrollments.where(path_id: @path.id).first
      
      multiplier = @multipliers[@easy]
      completed_task_count = 3
      average_score = 100
      score = 0
      completed_task_count.times do |i|
        score += average_score * multiplier
      end
      computed_metascore = score / completed_task_count
      computed_metascore.should == 100
      
      enrollment.calculate_metascore
      enrollment.metascore.should == computed_metascore
    end
    
    it "expert difficulty" do
      3.times { FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EXPERT) }
      complete_tasks(@path.tasks, @user, 100)
      enrollment = @user.enrollments.where(path_id: @path.id).first
      
      multiplier = @multipliers[@expert]
      completed_task_count = 3
      average_score = 100
      score = 0
      completed_task_count.times do |i|
        score += average_score * multiplier
      end
      computed_metascore = score / completed_task_count
      computed_metascore.should == 400
      
      enrollment.calculate_metascore
      enrollment.metascore.should == computed_metascore
    end
    
    it "mixed difficulty" do
      2.times { FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EASY) }
      2.times { FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EXPERT) }
      complete_tasks(@path.tasks, @user, 100)
      enrollment = @user.enrollments.where(path_id: @path.id).first
      
      
      completed_task_count = 4
      average_score = 100
      score = 0
      
      multiplier = @multipliers[@easy]
      2.times { score += average_score * multiplier } # 200
      
      multiplier = @multipliers[@expert]
      2.times { score += average_score * multiplier } # 800
      
      score.should == 1000
      computed_metascore = score / completed_task_count # 250
      computed_metascore.should == 250
      
      enrollment.calculate_metascore
      enrollment.metascore.should == computed_metascore
    end
    
    it "mixed difficulty and score" do
      4.times { FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EASY) }
      4.times { FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EXPERT) }
      complete_tasks(@path.tasks.where(difficulty: Task::EASY).first(2), @user, 100)
      complete_tasks(@path.tasks.where(difficulty: Task::EASY).last(2), @user, 50)
      complete_tasks(@path.tasks.where(difficulty: Task::EXPERT).first(2), @user, 100)
      complete_tasks(@path.tasks.where(difficulty: Task::EXPERT).last(2), @user, 75)
      enrollment = @user.enrollments.where(path_id: @path.id).first
      
      
      completed_task_count = 8
      score = 0
      
      average_score = 100
      multiplier = @multipliers[@easy]
      2.times { score += average_score * multiplier } # 200
      
      average_score = 50
      multiplier = @multipliers[@easy]
      2.times { score += average_score * multiplier } # 100
      
      average_score = 100
      multiplier = @multipliers[@expert]
      2.times { score += average_score * multiplier } # 800
      
      average_score = 75
      multiplier = @multipliers[@expert]
      2.times { score += average_score * multiplier } # 2 * ( 75 * 4 ) = 600
      
      score.should == 1700
      computed_metascore = (score.to_f / completed_task_count).to_i # 1700 / 8 = 212.5
      computed_metascore.should == (212.5).to_i
      
      enrollment.calculate_metascore
      enrollment.metascore.should == computed_metascore
    end
  end
end