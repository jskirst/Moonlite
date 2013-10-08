require 'spec_helper'

describe "Professional Registration" do
  before :each do
    @user = init_metabright
  end
  
  describe "User" do
    it "should be able to professionally register for MB", js: true do
      path = FactoryGirl.create(:path_with_tasks, user: @user)
      
      visit root_path
      
      expect_content("Prove your skills.")
    
      click_button "Get Started"
      find("#challenge_start_#{path.permalink}").click
      
      expect_content("Looks like you're new here...")
      first('.answer_content').click
      click_on "Let's Go!"
      
      expect_content(path.name)
      first('.answer_content').click
      click_on "Next"
      
      expect_content(path.name)
      first('.answer_content').click
      click_on "Next"
      
      expect_content(path.name)
      first('.answer_content').click
      click_on "Next"
      
      expect_content(path.name)
      first('.answer_content').click
      click_on "Next"
      
      expect_content(path.name)
      first('.answer_content').click
      click_on "Next"
      
      expect_content(path.name)
      first('.answer_content').click
      click_on "Next"
      
      expect_content(path.name)
      first('.answer_content').click
      click_on "Next"
      
      expect_content("Not bad...")
      click_on "I'm ready!"
      
      expect_content("Boss Question!")
      find("#answer_input").set("Blah")
      click_on "Submit"
      
      expect_content("Nice work!")
      click_on "Continue"
      
      expect_content("MetaBright is the game that can land you your next job or internship.")
      click_on "Try it out!"
      
      expect_content("We just need a few details...")
      first('.checkbox').click
      find('#user_country').click
      find('US').click
      find("#user_city").set("city")
      
      expect_content("You're almost done!")
      find("#user_name").set("name")
      find("#user_email").set("email@mailinator.com")
      find("#user_password").set("password")
      click_on "Submit"
      
      expect_content("You're all done!")
    end
  end
end
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      
      