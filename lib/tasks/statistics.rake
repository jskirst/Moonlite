task :statistics => :environment do
  users = User.joins(:user_role)
    .where("user_roles.enable_administration = ?", false)
    .where("locked_at is ?", nil)
    .where("is_fake_user = ? or is_test_user = ?", false, false)
    .where("earned_points > 0")
    
  puts "Total Active Users: " + users.count.to_s
  
  completed_tasks = CompletedTask.where("user_id in (?)", users.collect(&:id))
  
  puts "Total Completed Tasks: " + completed_tasks.count.to_s
  
  puts "Avg Completed Tasks: " + (completed_tasks.count / users.count).to_s
end