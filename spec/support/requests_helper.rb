module RequestsHelper
  def init_metabright
    persona = FactoryGirl.create(:persona_with_paths, name: "First Persona")
    user = FactoryGirl.create(:user)
    FactoryGirl.create(:path_with_tasks, user: user)
    return user
  end
  
  def sign_in(user)
    Capybara.reset_sessions!
    visit '/signin'
    expect_content("Sign in to MetaBright")
    fill_in "session_email", with: user.email
    fill_in "session_password", with: "a1b2c3d4"
    click_button "Sign In"
    expect_content(user.name)
  end
  
  def expect_content(str)
    begin
      page.should have_content(str)
    rescue
      save_and_open_page
      raise "Expected '#{str}': #{$!}"
    end
  end
  
  def not_expect_content(str)
    begin
      page.should_not have_content(str)
    rescue
      save_and_open_page
      raise "Did not expect #{str}"
    end
  end
end