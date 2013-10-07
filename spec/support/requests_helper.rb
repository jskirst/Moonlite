module RequestsHelper
  def init_metabright
    persona = FactoryGirl.create(:persona_with_paths, name: "First Persona")
    user = User.first
    persona.paths.each { |p| FactoryGirl.create(:task, path: p, creator_id: user.id) }
    #raise user.to_yaml
    return user
  end
  
  def sign_in(user)
    visit '/signin'
    fill_in "session_email", with: user.email
    fill_in "session_password", with: "a1b2c3d4"
    click_button "Sign In"
    expect_content("EXPLORE THE WORLD OF METABRIGHT")
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