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

task :test_notifications => :environment do
  desc "Resetting notifications..."
  UserEvent.all.each do |u|
    u.read_at = nil
    u.save
  end
end