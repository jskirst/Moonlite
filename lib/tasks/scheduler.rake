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