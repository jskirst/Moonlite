require 'spec_helper'

describe "Registration" do
  before :each do
    init_metabright
  end
  
  describe "through new user page" do
    it "should allow email/password registration" do
      visit root_path
      find("a.register_link").click
      
      expect_content("I want to prove my skills and make myself more marketable.")
      find("a[description='link-to-registration']").click
      
      sleep(4)
      expect_content("Sign up for MetaBright")
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

  describe "through challenge" do
    before :each do
      path = FactoryGirl.create(:path_with_tasks)
      
      visit root_path
      
      expect_content("Prove your skills.")
      click_button "Get Started"
      find("#challenge_start_#{path.permalink}").click
      
      expect_content("Looks like you're new here...")
      first('.answer_content').click
      click_on "Let's Go!"
  
      7.times do
        expect_content(path.name)
        first('.answer_content').click
        click_on "Next"
      end
      
      expect_content("Not bad...")
      click_on "I'm ready!"
      
      expect_content("Boss Question!")
      find("#answer_input").set("Blah")
      click_on "Submit"
      
      expect_content("Nice work!")
      click_on "Continue"
  
      expect_content("MetaBright is the game that can land you your next job or internship.")
    end
  
    it "should be able to professionally register for MB" do
      click_on "Try it out!"
      
      expect_content("We just need a few details...")
      find(:css, "#user_wants_part_time").set(true)
      select "Afghanistan", from: "user_country"
      select "Balkh", from: "user_state"
      find("#user_city").set("San Francisco")
      click_on "Continue to Register"
      
      expect_content("You're almost done!")
      find("#user_name").set("name")
      find("#user_email").set("email@mailinator.com")
      find("#user_password").set("password")
      click_on "Submit"
      
      expect_content("You're all done!")
    end
  
    it "should be able to unprofessionally register for MB" do
      click_on "No thanks, I'll just play MetaBright as a game."
      
      expect_content("Keep racking up the points!")
      fill_in "user_name", with: "My Name"
      fill_in "user_email", with: "email@mailinator.com"
      fill_in "user_password", with: "password"
      find("input[type=submit]").click
      
      expect_content("You're all done!")
    end
  end
end