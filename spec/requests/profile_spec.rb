require 'spec_helper'

describe "Profile" do
  before :each do
    @user = init_metabright
  end
  
  # describe "follow button", js: true do
  #    it "should follow an unfollowed user and unfollow a followed user" do
  #      sign_in(@user)
  #      @user2 = FactoryGirl.create(:user)
  #      visit profile_path(@user2.username)
  #      expect_content(@user2.name)
  #      
  #      click_on "Follow"
  #      expect_content("Following")
  #      @user.following?(@user2).should be_true
  #      
  #      click_on "Following"
  #      expect_content("Follow")
  #      
  #      visit profile_path(@user2.username)
  #      expect_content(@user2.name)
  #      @user.following?(@user2).should_not be_true
  #    end
  #  end
  #  
  #  describe "edit profile button" do
  #    it "should load profile editor" do
  #      sign_in(@user)
  #      visit profile_path(@user.username)
  #      expect_content(@user.name)
  #      find("#topprofilecontent a").click
  #      
  #      expect_content("Edit Profile")
  #      click_on "Customize Profile"
  #    end
  #  end
  
  describe "enrollments", js: true do
    before :each do 
      @completed_paths = []
      3.times do
        user = FactoryGirl.create(:user)
        path = FactoryGirl.create(:path_with_tasks, user: user)
        complete_path(path, @user)
        @completed_paths << path
      end
      visit profile_path(@user.username)
    end
    
    it "should all display with correct question statistics" do
      @completed_paths.each do |p|
        find("#challenge_selector_#{p.permalink}").click
        expect_content("Find more #{p.name} experts at MetaBright")
        completed_tasks = CompletedTask.joins(:task).where("tasks.path_id = ? and completed_tasks.user_id = ?", p.id, @user.id)
        
        core_tasks = completed_tasks.where("tasks.answer_type" => Task::MULTIPLE).count.to_s
        find("h3.questions-correct-count").text.should eq(core_tasks)
        #find("h3.longest-streak-count").text.should eq(core_tasks)
        #find("h3.highest-rank-count").text.should eq(1.to_s)
        
        creative_tasks = completed_tasks.where("tasks.answer_type" => Task::CREATIVE)
        creative_tasks.each do |ct| 
          expect_content(ct.task.question)
          expect_content(ct.submitted_answer.content)
        end
        
        checkin_tasks = completed_tasks.where("tasks.answer_type" => Task::CHECKIN)
        checkin_tasks.each do |ct| 
          expect_content(ct.task.question)
          expect_content(ct.submitted_answer.title)
        end
      end
    end
  end
end