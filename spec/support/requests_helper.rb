module RequestsHelper
  def init_metabright
    raise "EXISTING PERSONAS" unless Persona.count == 0
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
  end
  
  def complete_path(path, user)
    complete_tasks(path.tasks, user)
  end
  
  def complete_tasks(tasks, user, score = 100)
    tasks.each do |t|
      complete_task(t, user, score)
    end
  end
  
  def complete_task(t, user, score = 100)
    ct = CompletedTask.find_or_create(user.id, t.id)
    raise "Invalid completed task" unless ct.id
    if t.multiple_choice?
      if score == 0
        ct.complete_core_task!("", 0)
      else
        ct.complete_core_task!(t.correct_answer.content, score)
      end
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
  
  def expect_content(str)
    begin
      wait_until("Page has '#{str}'", 10){ page.has_content?(str) }
    rescue
      save_and_open_page
      raise "Expected '#{str}': #{$!}"
    end
  end

  def wait_until(event = "event", max_wait = 30, &block)
    start = Time.now
    until yield(block) do
      sleep(0.1)
      if waited(start) > max_wait
        raise "#{event} timed out."
      end
    end
  end
  
  def waited(start)
    Time.now - start
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