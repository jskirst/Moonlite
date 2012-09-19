task :usage_report => :environment do
  start = Time.now
  puts "Starting test task..."
  Company.all.each do |c|
    user_details = [["Name", "Email", "Motto", "Is Motto", "Is Registered", "Is Facebook", "Is Google", "# Enrolled Paths", "# Completed Paths", "# Correct Answers", "# Incorrect Answers", "Last Action", "Last Login At", "Created At Date"]]
    c.users.where("is_test_user = ? and is_fake_user = ?", false, false).all(:order => "id DESC").each do |u|
      user_details_row = [u.name, u.email, u.catch_phrase.to_s]
      user_details_row << (u.catch_phrase.blank? ? 0 : 1)
      user_details_row << (u.email.include?("anonymous") ? 0 : 1)      
      
      user_auths = u.user_auths
      provider = user_auths.first.provider unless user_auths.empty?
      user_details_row << (provider == "facebook" ? 1 : 0)
      user_details_row << (provider == "google_oauth2" ? 1 : 0)
      
      user_details_row.concat([u.usage("enrolled_paths"), u.usage("completed_paths"), u.usage("correct_answers"), u.usage("incorrect_answers")])
      user_details_row.concat([u.usage("last_action"), u.login_at.to_s, u.created_at])
      user_details << user_details_row
    end
    csv_report = UsageReport.generate_csv_report(user_details)
    c.usage_reports.create!(:name => "Test Report", :report => File.open("#{Rails.root}/tmp/file.csv", "r"))
  end
  puts "Completed test task."
  puts "Run time: #{(Time.now - start).to_s} seconds"
end

task :refresh_staging => :environment do
  starting_time = Time.now
  puts "Reseting staging database..."
  `heroku pg:reset DATABASE --app fierce-stone-6508 --confirm fierce-stone-6508`
  puts "Creating backup..."
  `heroku pgbackups:capture --app moonlite --expire`
  puts "Getting backup url..."
  url = `heroku pgbackups:url --app moonlite`
  url = url.gsub("\r","").gsub("\n","")
  puts "Restoring backup url to staging..."
  cmd = 'heroku pgbackups:restore DATABASE "'+url+'" --app fierce-stone-6508 --confirm fierce-stone-6508'
  puts cmd
  system(cmd)
  puts "Migrating database..."
  `heroku run rake db:migrate --remote staging`
  puts "Completed run."
  ending_time = Time.now
  puts "Total run time: #{ending_time - starting_time} seconds."
end

task :send_completed_scores => :environment do  
  puts "Completing any remaining enrollments that were delayed for grading"
  Path.all.each do |p|
    if p.has_creative_response
      p.enrollments.where("is_complete = ?", false).each do |e|
        if p.total_remaining_tasks(e.user) == 0
          if p.completed_tasks.where("user_id = ? and status_id = ?", e.user.id, 2).count == 0
            e.update_attribute(:is_complete, true)
            p.create_completion_event(e.user, e.user.company.name_for_paths)
            puts "completing #{p.name} for #{e.user.name}"
          else
            puts "not completing #{p.name} for #{e.user.name}"
          end
        end
      end
    end
  end
  
  puts "Starting to send completed scores."
  @paths = Path.where("passing_score is not ?", nil)
  puts "Paths that are pass/fail: #{@paths.size}"
  @paths.each do |p|
    puts "Processing #{p.name}"
    passing_score = p.passing_score
    puts "Passing score: #{passing_score}"
    @unsent_enrollments = p.enrollments.where("is_complete = ? and is_score_sent = ?", true, false) 
    puts "Unsent emails:#{@unsent_enrollments.size}"
    @unsent_enrollments.each do |e|
      if ENV["EMAIL"] && ENV["EMAIL"] != e.user.email
        puts "skipping user #{e.user.email}"
        next
      else
        puts "not skipping #{e.user.email}"
      end 
      
      user = e.user
      puts "Sending to #{user.email}"
      score = p.percentage_correct(user)
      puts "Score: #{score}"
      e.is_passed = score >= passing_score
      e.percentage_correct = score
      e.save
      puts e.to_yaml
      if e.send_result_email
        e.is_score_sent = true
        raise "Could not save unsent enrollment." + e.to_yaml unless e.save
      else
        raise "Could not send result email." + e.to_yaml
      end
      puts "Email sent."
    end
  end
end

task :clean_up_hanging_blobs => :environment do
  SubmittedAnswer.all.each do |sa|
    unless CompletedTask.where("submitted_answer_id = ?", sa.id).count > 0
      sa.destroy
    end
  end
end