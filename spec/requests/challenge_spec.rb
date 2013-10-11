require 'spec_helper'

describe "Challenge" do
  before :each do
    creator = init_metabright
    @path = FactoryGirl.create(:path_with_tasks, user: creator)
    @user = FactoryGirl.create(:user)
    enrollment = @user.enroll!(@path)
    enrollment.update_attribute(:total_points, 1)
    sign_in(@user)
  end
  
  describe "launchpad", js: true do
    before :each do
      visit challenge_path(@path.permalink)
      find("#launch_button").click
    end
      
    it "should display creative response and tasks" do
      expect_content "Arena"
      expect_content "Creative Response"
      expect_content "Tasks"
      
      find("#achievements_tab").click
      first(".task-row").first("a").click
      expect_content("Submit")
    end
  end
end