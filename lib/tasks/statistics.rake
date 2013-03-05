task :statistics => :environment do
  users = User.joins(:user_role)
    .where("user_roles.enable_administration = ?", false)
    .where("locked_at is ?", nil)
    .where("is_fake_user = ? or is_test_user = ?", false, false)
    .where("earned_points > 0")
    
  puts "Total Active Users: " + users.count.to_s
  
  completed_tasks = CompletedTask.joins(:user => :user_role)
    .where("user_roles.enable_administration = ?", false)
    .where("locked_at is ?", nil)
    .where("is_fake_user = ? or is_test_user = ?", false, false)
    .where("earned_points > 0")
  
  puts "Total Completed Tasks: " + completed_tasks.count.to_s
  
  puts "Avg Completed Tasks: " + (completed_tasks.count / users.count).to_s
  
  visits = Visit.joins(:user => :user_role)
    .where("user_roles.enable_administration = ?", false)
    .where("locked_at is ?", nil)
    .where("is_fake_user = ? or is_test_user = ?", false, false)
    .where("earned_points > 0")
    .order("user_id ASC, id ASC")
  
  puts "Total Visits: " + visits.count.to_s
  
  session_start = nil
  last_visit = nil
  user_sessions = {}
  time_limit = (ENV["TIME_LIMIT"] || 5).to_i
  
  visits.each do |visit|
    if last_visit.nil? || last_visit.user_id != visit.user_id
      last_visit = visit
      session_start = visit
      if user_sessions[visit.user_id].nil?
        user_sessions[visit.user_id] = { visit.id => [visit] }
      end
      next
    end
    
    if last_visit.updated_at > (visit.created_at - time_limit.minutes)
      user_sessions[visit.user_id][session_start.id] << visit
    else
      session_start = visit
      user_sessions[visit.user_id][visit.id] = [visit]
    end
    last_visit = visit
  end
  
  minimum_time = (ENV["MINIMUM_TIME"] || 10).to_i
  times = []
  user_sessions.each do |user, sessions|
    starts = sessions.keys
    starts.each do |s|
      if sessions[s].size == 1
        times << s.created_at == s.visited_at ? minimum_time : (s.updated_at - s.created_at)
      else
        times << (sessions[s].last.updated_at - sessions[s].first.created_at) / 60
      end
    end
  end
  
  puts times.to_yaml
  puts times.inject(0){ |total_time, session| total_time += session } / times.size
end