require 'spec_helper'

describe "Registration" do
  before :each do
    init_metabright
  end
  
  describe "through new user page" do
    it "should allow email/password registration" do
      visit root_path
      find("a.register_link").click
      find("a[description='link-to-registration']").click
      
      fill_in "user_name", with: "Test User"
      fill_in "user_email", with: "testuser@t.com"
      fill_in "user_password", with: "testpassword"
      click_on "Submit"
      
      user = User.last
      user.name.should == "Test User"
      user.username.should == "testuser"
      user.email.should == "testuser@t.com"
      
      User.authenticate("testuser@t.com", "testpassword").should == user
    end
  end
end