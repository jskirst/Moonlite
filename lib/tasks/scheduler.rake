task :send_alerts => :environment do
  puts "VOTE ALERTS"
  votes = Vote.where("created_at > ?", 10.minutes.ago)
  votes.each do |vote|
    begin
      Mailer.content_vote_alert(vote).deliver
      puts "Vote alert sent"
    rescue
      puts "Vote alert rejected."
    end
  end
  
  puts "FOLLOW ALERTS"
  subs = Subscription.where("created_at > ?", 10.minutes.ago)
  subs.each do |sub|
    begin
      Mailer.content_vote_alert(sub).deliver
      puts "Sub alert sent"
    rescue
      puts "Sub alert rejected."
    end
  end
  
  puts "COMMENT ALERTS"
  comments = Comment.where("created_at > ?", 10.minutes.ago)
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
  enrollments = Enrollment.where("contribution_unlocked_at > ?", 10.minutes.ago)
  enrollments.each do |e|
    puts "Sending contribution unlock alert..."
    begin
      Mailer.contribution_unlocked(e.user.email, e.path).deliver
    rescue
      puts "Contribution Unlock alert rejected: #{$!}"
    end
  end
end

task :send_newsletter => :environment do
  raise "Fatal: No newsletter specified" unless ENV["NEWSLETTER_PATH"]
  if ENV["NEWSLETTER_TEST"]
    puts "Sending to test..."
    Newsletters.newsletter(ENV["NEWSLETTER_TEST"], ENV["NEWSLETTER_PATH"], ENV["NEWSLETTER_SUBJECT"]).deliver
  else
    puts "Sending to all users..."
    User.where("locked_at is ?", nil).each do |user|
      begin
        Newsletters.newsletter(user.email, ENV["NEWSLETTER_PATH"], ENV["NEWSLETTER_SUBJECT"]).deliver
      rescue
        puts "Newsletter alert rejected: #{$!}"
      end
    end
  end    
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
  class Score
    attr_accessor :value, :percentile, :enrollment
    def initialize(score, enrollment)
      self.value = score.to_f
      self.enrollment = enrollment
    end
    def <=>(foo)
      self.value <=> foo.value
    end
  end

  PATH_AVERAGES = {}
  Path.all.each do |path|
    cts = path.completed_tasks.where("answer_type in (?)", [Task::MULTIPLE, Task::EXACT])
    enrollments = path.enrollments.where(total_points: 0).count
    stats = {
      tasks_attempted: (cts.count / (enrollments == 0 ? 1 : enrollments)),
      percent_correct: (cts.where("status_id = ?", Answer::CORRECT).count.to_f / cts.count),
      correct_points: (cts.where("status_id = ?", Answer::CORRECT).average(:points_awarded).to_f)
    }
    PATH_AVERAGES[path.id] = stats
  end
  
  Enrollment.where(metascore: 0).each { |e| e.get_metascore; puts e.metascore.to_s }

  scores = []
  Enrollment.where("metapercentile = ?", 0).each do |e|
    scores << Score.new(e.metascore, e.id)
  end
  scores.sort!
  scores_count = scores.size

  # iterate through scores and calculate percentile
  scores.each_with_index do |s, i|

    # L/N(100) = P
    # L = number of scores beneath this score (score array index)
    # N = total number of scores
    # P = percentile
    e = Enrollment.find(s.enrollment)
    percentile = (i.to_f/scores_count.to_f*100).ceil
    e.update_attribute(:metapercentile, percentile)
    puts "#{e.id}: #{e.metascore} , #{e.metapercentile}"
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