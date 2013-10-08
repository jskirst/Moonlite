require 'spec_helper'

describe "Labs" do
  before :each do
    @user = init_metabright
    sign_in(@user)
  end
  
  describe "User" do
    it "should be able to access and use Labs", js: true do
      visit ideas_path
      
      expect_content("Help shape the MetaBright roadmap")
      click_on "Bugs"
      
      expect_content("Post New Bug")
      click_on "Post New Bug"
      
      expect_content("Submit a new Bug")
      find("#idea_title").set("Test Bug")
      find("#idea_description").set("Test Bug description")
      click_on "Submit Bug"
      
      expect_content("Test Bug")
      click_on "Ideas"
      
      expect_content("Post New Idea")
      click_on "Post New Idea"
      
      expect_content("Submit a new Idea")
      find("#idea_title").set("Test Idea")
      find("#idea_description").set("Test Idea description")
      click_on "Submit Idea"
      
      expect_content("Test Idea")
    end
  end
end