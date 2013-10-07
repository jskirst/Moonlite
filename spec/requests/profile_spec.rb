require 'spec_helper'

describe "Profile" do
  before :all do
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
    it "should load profile editor" do
      sign_in(@user)
      visit profile_path(@user.username)
      expect_content(@user.name)
      save_and_open_page
      click_on "Edit Profile"
      
      expect_content("Edit Profile")
      click_on "Customize Profile"
    end
  end
end