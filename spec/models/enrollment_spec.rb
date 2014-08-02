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
    
    it "all wrong, easy difficulty" do
      t1 = FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EASY)
      t2 = FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EASY)
      
      complete_task(t1, @user, 0)
      complete_task(t2, @user, 0)
      
      enrollment = @user.enrollments.where(path_id: @path.id).first
      
      enrollment.total_points.should == 0
      
      enrollment.calculate_metascore
      enrollment.reload
      enrollment.metascore.should == 300
    end
    
    it "all wrong, expert difficulty" do
      t1 = FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EXPERT)
      t2 = FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EXPERT)
      
      complete_task(t1, @user, 0)
      complete_task(t2, @user, 0)
      
      enrollment = @user.enrollments.where(path_id: @path.id).first
      
      enrollment.total_points.should == 0
      
      enrollment.calculate_metascore
      enrollment.reload
      enrollment.metascore.should == 300
    end
    
    it "easy difficulty" do
      t1 = FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EASY)
      t2 = FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EASY)
      t3 = FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EASY)
      
      complete_task(t1, @user, 100)
      complete_task(t2, @user, 100)
      complete_task(t3, @user, 100)
      
      enrollment = @user.enrollments.where(path_id: @path.id).first
      
      enrollment.total_points.should > 0
      
      enrollment.calculate_metascore
      enrollment.reload
      enrollment.metascore.should == 764
    end
    
    it "expert difficulty" do
      3.times { FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EXPERT) }
      complete_tasks(@path.tasks, @user, 100)
      enrollment = @user.enrollments.where(path_id: @path.id).first
      
      enrollment.calculate_metascore
      enrollment.metascore.should == 850
    end
    
    it "mixed difficulty" do
      2.times { FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EASY) }
      2.times { FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EXPERT) }
      complete_tasks(@path.tasks, @user, 100)
      enrollment = @user.enrollments.where(path_id: @path.id).first
      
      enrollment.calculate_metascore
      enrollment.metascore.should == 850
    end
    
    # it "mixed difficulty and score" do
    #   4.times { FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EASY) }
    #   4.times { FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EXPERT) }
    #   complete_tasks(@path.tasks.where(difficulty: Task::EASY).first(2), @user, 100)
    #   complete_tasks(@path.tasks.where(difficulty: Task::EASY).last(2), @user, 50)
    #   complete_tasks(@path.tasks.where(difficulty: Task::EXPERT).first(2), @user, 100)
    #   complete_tasks(@path.tasks.where(difficulty: Task::EXPERT).last(2), @user, 75)
    #   enrollment = @user.enrollments.where(path_id: @path.id).first
      
    #   enrollment.calculate_metascore
    #   enrollment.metascore.should == 808
    # end
    
    it "half right half wrong, mixed difficulty" do
      t1 = FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EASY)
      t2 = FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EXPERT)
      t3 = FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EASY)
      t4 = FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EXPERT)
      
      complete_task(t1, @user, 0)
      complete_task(t2, @user, 0)
      complete_task(t3, @user, 100)
      complete_task(t4, @user, 100)
      
      enrollment = @user.enrollments.where(path_id: @path.id).first
      
      enrollment.calculate_metascore
      enrollment.metascore.should == 412
    end
    it "three right one wrong, mixed difficulty" do
      t1 = FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EASY)
      t2 = FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::EXPERT)
      t3 = FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::HARD)
      t4 = FactoryGirl.create(:multiple_choice_task, path: @path, section: @section, creator: @path.user, difficulty: Task::MEDIUM)
      
      complete_task(t1, @user, 0)
      complete_task(t2, @user, 100)
      complete_task(t3, @user, 100)
      complete_task(t4, @user, 100)
      
      enrollment = @user.enrollments.where(path_id: @path.id).first
      
      enrollment.calculate_metascore
      enrollment.metascore.should == 617
    end
  end
end