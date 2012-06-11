task :test_task => :environment do
    puts "Starting test task..."
    Company.all.each do |c|
      user_details = [["Name", "Email", "Motto", "# Enrolled Paths", "# Completed Paths", "# Correct Answers", "# Incorrect Answers", "Last Action", "Last Login At", "Created At Date"]]
      c.users.all.each do |u|
        user_details << [u.name, u.email, u.catch_phrase.to_s, u.usage("enrolled_paths"), u.usage("completed_paths"), u.usage("correct_answers"), u.usage("incorrect_answers"), u.usage("last_action"), u.login_at.to_s, u.created_at]
      end
      csv_report = UsageReport.generate_csv_report(user_details)
      c.usage_reports.create!(:name => "Test Report", :report => File.open("#{Rails.root}/tmp/file.csv", "r"))
    end
    puts "Completed test task."
end