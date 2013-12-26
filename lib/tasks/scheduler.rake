task :group_checkin => :environment do
  Group.send_all_checkin_emails(true)
end

task :send_alerts => :environment do
  time = 10.minutes.ago
  puts "VOTE ALERTS"
  votes = Vote.where("created_at > ?", time)
  votes.each do |vote|
    begin
      Mailer.content_vote_alert(vote).deliver
      puts "Vote alert sent"
    rescue
      puts "Vote alert rejected."
    end
  end
  
  puts "FOLLOW ALERTS"
  subs = Subscription.where("created_at > ?", time)
  subs.each do |sub|
    begin
      Mailer.content_sub_alert(sub).deliver
      puts "Sub alert sent"
    rescue
      puts "Sub alert rejected."
    end
  end
  
  puts "COMMENT ALERTS"
  comments = Comment.where("created_at > ?", time)
  comments.each do |comment|
    begin
      Mailer.content_comment_alert(comment).deliver
      puts "Comment alert sent"
      if comment.owner.comments.size > 1 && comment == comment.owner.comments.last
        puts "Submission has more than one comment..."
        alerted_users = []
        comment.owner.comments.each do |c|
          next if c == comment or c.user == comment.user or c.user == c.owner.user
          next if alerted_users.include?(c.user)
          alerted_users << c.user
          Mailer.comment_reply_alert(comment, comment.user, c.user).deliver
          puts "Comment reply alert sent"
        end
      end
    rescue
      puts "Comment alert rejected"
    end
  end
  
  puts "CONTRIBUTION UNLOCK ALERTS"
  enrollments = Enrollment.where("contribution_unlocked_at > ?", time)
  enrollments.each do |e|
    puts "Sending contribution unlock alert..."
    begin
      Mailer.contribution_unlocked(e.user.email, e.path).deliver
    rescue
      puts "Contribution Unlock alert rejected: #{$!}"
    end
  end
  
  puts "NEW GROUP WELCOME EMAILS"
  Group.send_all_welcome_emails(time, true)
  
  puts "NEW EVALUATION ENROLLMENT SUBMISSION EMAILS"
  EvaluationEnrollment.send_all_submission_alerts(time, true)
end

task :daily_alerts => :environment do
  time = Time.now - 24.hours
  puts "Sending daily alerts. Time Marker: #{time}"
  puts "VISIT ALERTS"
  Visit.send_all_visit_alerts(time, true)
  puts "INDUCTION ALERTS"
  SubmittedAnswer.send_all_induction_alerts(time, true)
  puts "Daily alerts finished."
end

task :order_by_easy => :environment do
  tasks = 0
  ineligible_tasks = 0
  eligible_tasks = 0
  updated_tasks = 0
  
  Task.all.each do |t|
    tasks += 1
    unless t.position.to_i > 100
      eligible_tasks += 1
      correct_count = t.completed_tasks.where(status_id: Answer::CORRECT).count
      total = t.completed_tasks.count
  
      total = 1 if total == 0
      correct_ratio = ((correct_count.to_f / total.to_f).to_f * 100).ceil
      unless correct_ratio == t.position
        updated_tasks += 1
        t.position = correct_ratio
        t.save
      end
    else
      ineligible_tasks += 1
    end
  end
  
  puts "Total Tasks: #{tasks}"
  puts "Ineligible Tasks: #{ineligible_tasks}"
  puts "Eligible Tasks: #{eligible_tasks}"
  puts "Updated Tasks: #{updated_tasks}"
end

task :metascore => :environment do
  # Score class
    
  Enrollment.where("total_points > 0").each { |e| e.calculate_metascore; puts e.metascore.to_s }
  Enrollment.where("total_points = 0").each { |e| e.update_attributes(metascore: 0, metapercentile: 0) }

  # iterate through scores and calculate percentile
  Path.all.each do |p|
    scores = Enrollment.scores(p)
    Enrollment.where(path_id: p.id).where("total_points > ?", 0).each_with_index do |e|
      e.calculate_metapercentile(scores)
      puts "#{e.id}: #{e.metascore} , #{e.metapercentile}"
    end
  end
end

task :update_streak_and_rank => :environment do
  enrollments = 0
  updated_streaks = 0
  updated_ranks = 0
  Enrollment.all.each do |e|
    enrollments += 1
    streak = 0
    longest_streak = 0
    e.completed_tasks.joins(:task).where("tasks.answer_type = ?", Task::MULTIPLE).order("completed_tasks.id ASC").each do |ct|
      unless ct.correct?
        streak = 0
      else
        streak += 1
        longest_streak = streak if streak > longest_streak
      end
    end
    
    unless e.longest_streak == longest_streak
      updated_streaks += 1
      e.longest_streak = longest_streak
    end
    
    unless e.highest_rank > e.rank or e.highest_rank == e.rank
      updated_ranks += 1
      e.highest_rank = e.rank 
    end
    
    e.save
  end
  
  puts "Total Enrollments: #{enrollments}"
  puts "Updated Streaks: #{updated_streaks}"
  puts "Updated Ranks: #{updated_ranks}"
end

task :test_send_follow_alert => :environment do
  puts "SUBSCRIPTION ALERTS"
  subscriptions = Subscription.where("created_at > ?", 10.minutes.ago)
  subscriptions.each do |subscription|
    begin
      Mailer.content_sub_alert(subscription).deliver
      puts "Subscription alert sent"
    rescue
      puts "Subscription alert rejected."
    end
  end
end

task :set_latitude_and_longitude => :environment do
  require 'geocoder'
  
  @locations = User.select("DISTINCT on (city, state, country) city, state, country")
    .where("state is not ? and country is not ?", nil, nil)
    .where("users.latitude is ? or users.longitude is ?", nil, nil).group("city, state, country").to_a
  puts "Found #{@locations.size} locations."
  
  @locations.each do |l|
    puts l.to_yaml
    computed_location = Geocoder.search([l.city, l.state, l.country].join(", ")).first
    next if computed_location.nil?
    lat = computed_location.data["geometry"]["location"]["lat"]
    lng = computed_location.data["geometry"]["location"]["lng"]
    puts "#{lat}, #{lng}"
  
    @users = User.where("city = ? and state = ? and country = ?", l.city, l.state, l.country)
    puts "Found #{@users.count} with this location."
    @users.update_all("latitude = #{lat}, longitude = #{lng}")
  end
end

task :failing_task => :environment do
  puts "Failing task in environment #{Rails.env}..."
  FAIL!
end

task :cache_warmup => :environment do
  ap Rails.cache.stats
  
  Rails.cache.clear

  start = Time.now
  
  puts "Loading answers..."
  #Answers
  a = Answer.last.id
  (1..a).each do |i|
    Answer.cached_find(i)
  end
  Task.all.each do |t|
    Answer.cached_find_by_task_id(t.id)
  end
  
  puts "Loading comments..."
  #Comments
  SubmittedAnswer.all.each do |sa|
    Comment.cached_find_by_owner_type_and_owner_id("SubmittedAnswer", sa.id)
  end
  
  puts "Loading groups..."
  #Group
  User.all.each do |u|
    Group.cached_find_by_user_id(u.id)
  end
  
  puts "Loading paths..."
  #Path
  permalinks = Path.all.collect(&:permalink)
  permalinks.each do |permalink|
    Path.cached_find(permalink)
  end
  p = Path.all.last.id
  (1..a).each do |i|
    Path.cached_find_by_id(i)
  end
  Persona.all.each do |persona|
    Path.cached_find_by_persona_id(persona.id)
  end
  
  puts "Loading personas..."
  #Persona
  Persona.cached_personas
  
  puts "Loading sections..."
  #Section
  s = Section.all.last.id
  (1..s).each do |i|
    Section.cached_find(i)
  end
  
  puts "Loading submitted answers..."
  #Submitted Answer
  s = SubmittedAnswer.all.last.id
  (1..s).each do |i|
    SubmittedAnswer.cached_find(i)
  end
  
  puts "Loading tasks..."
  #Task
  t = Task.all.last.id
  (1..t).each do |i|
    Task.cached_find(i)
  end
  
  puts "Loading users..."
  #User
  usernames = User.all.collect(&:username)
  usernames.each do |username|
    User.cached_find_by_username(username)
  end
  u = User.all.last.id
  (1..u).each do |i|
    User.cached_find_by_id(i)
  end
  
  puts "Loading user events..."
  #UserEvent
  UserEvent.all.each do |u|
    UserEvent.cached_find_by_user_id(u.id)
  end
  
  ap Rails.cache.stats
  puts "Finished. Running time: #{Time.now - start}"
end
