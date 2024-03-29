require 'spec_helper'

describe "Custom Styles" do
  before :each do
    @user = init_metabright
    sign_in(@user)
  end
  
  describe "User" do
    it "should be able to access custom styles through edit profile" do
      visit edit_user_path(@user.username)
      click_on "Customize Profile"
      
      find("#custom_style_styles").set("my value")
      click_on "Save"
      
      expect_content("ERROR")

      select "On", from: "custom_style_mode"
      find("#custom_style_styles").set("my value")
      click_on "Save"
      
      expect_content("ERROR")
      select "On", from: "custom_style_mode"
      find("#custom_style_styles").set("body { padding: 10px; }")
      click_on "Save"
      
      expect_content("Your styles have been saved.")
    end
  end
end