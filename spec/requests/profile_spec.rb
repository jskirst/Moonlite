require 'spec_helper'

describe "Profile" do
  before :each do
    @user = init_metabright
  end
  
  describe "follow button" do
    it "should follow an unfollowed user and unfollow a followed user" do
       sign_in(@user)
       @user2 = FactoryGirl.create(:user)
       visit profile_path(@user2.username)
       expect_content(@user2.name)
       
       click_on "Follow"
       expect_content("Following")
       @user.following?(@user2).should be_true
       
       click_on "Following"
       expect_content("Follow")
       
       visit profile_path(@user2.username)
       expect_content(@user2.name)
       @user.following?(@user2).should_not be_true
     end
   end
   
  describe "edit profile button" do
    before :each do
      sign_in(@user)
      visit profile_path(@user.username)
      expect_content(@user.name)
      find("#topprofilecontent a").click
      expect_content "Edit Profile"
    end

    it "should allow access to custom profile editor" do
      click_on "Customize Profile"
      expect_content "Edit the styles below"
      # Tested further in requests/custom_styles_spec
    end

    it "should allow access to notification settings" do
      click_on "Manage your notification settings."

      expect_content "When do you want to receive emails from MetaBright?"
      check "notification_settings_inactive"
      click_on "Save"
      expect_content "Your notification settings have been saved. Rock on."
      @user.reload
      @user.notification_settings.inactive.should be_true
    end

    it "should allow access to professional settings" do
      click_on "Edit professional settings"
      check "user_wants_full_time"
      select "Albania", from: "user_country"
      sleep 0.5
      select "Fier", from: "user_state"
      fill_in "user_city", with: "Booga Booga"
      find("input[descriptor='save-button']").trigger("click")

      expect_content "Your settings have been saved. Rock on."
      @user.reload
      @user.country.should == "AL"
      @user.state.should == "04"
      @user.city.should == "Booga Booga"
      @user.wants_full_time.should be_true
      @user.wants_part_time.should be_false
      @user.wants_internship.should be_false
    end
  end
  
  describe "enrollments" do
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
      sleep(3)
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
          expect_content(ct.submitted_answer.title)
        end
      end
    end
  end
  
  describe "blank profile" do
    before :each do
      sign_in(@user)
      @user2 = FactoryGirl.create(:user)
    end
  
    it "should display" do
      #Odd case seen in production where user might have user persona but no enrollments
      @user2.user_personas.create!(persona_id: Persona.first.id)
      visit profile_path(@user2.username)
      expect_content(@user2.name)
    end
  end
end