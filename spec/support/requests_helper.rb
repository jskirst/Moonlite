module RequestsHelper
  def init_metabright
    persona = FactoryGirl.create(:persona_with_paths, name: "First Persona")
    user = FactoryGirl.create(:user)
    path = FactoryGirl.create(:path_with_tasks, user: user)
    raise "NO TASKS" unless path.tasks.count > 0
    raise "MULTIPLE PERSONAS" unless Persona.count == 1
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
  
  def complete_path(path, user)
    cts = []
    path.tasks.each do |t|
      ct = CompletedTask.find_or_create(user.id, t.id)
      raise "Invalid completed task" unless ct.id
      cts << ct
      if t.multiple_choice?
        ct.complete_core_task!(t.correct_answer.content, 100)
      elsif t.text?
        sa = t.submitted_answers.new
        sa.submit!(ct, user, true, { content: "Test Content" })
        sa.update_attribute(:reviewed_at, Time.now)
      elsif t.checkin?
        sa = t.submitted_answers.new
        sa.submit!(ct, user, true, { image_url: "/assets/test.jpg", title: Faker::Lorem.sentence(1) })
      else
        raise "Unknown question type: #{t.to_yaml}"
      end
    end
    raise "BAD CT COUNT" unless cts.size == path.tasks.count
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