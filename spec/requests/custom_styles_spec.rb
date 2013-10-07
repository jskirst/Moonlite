require 'spec_helper'

describe "Custom Styles" do
  before :all do
    @user = init_metabright
    sign_in(@user)
  end
  
  describe "User" do
    it "should be able to access custom styles through edit profile" do
      visit profile_path(@user.username)
      
      expect_content(@user.name)
      click_on "Edit Profile"
      
      expect_content("Edit Profile")
      click_on "Customize Profile"
      
      page.should have_content("Customize your Profile")
    end
  end
end