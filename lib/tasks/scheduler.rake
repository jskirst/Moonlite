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
  desc "Sending alerts..."
  votes = Vote.where("created_at > ?", 10.minutes.ago)
  votes.each do |vote|
    puts "Sending vote alert..."
    Mailer.content_vote_alert(vote).deliver
  end
  
  puts "Sending comment alerts..."
  comments = Comment.where("created_at > ?", 10.minutes.ago)
  comments.each do |comment|
    puts "Sending comment alert..."
    Mailer.content_comment_alert(comment).deliver
  end
end

task :reset_leaderboard => :environment do
  desc "Resetting leaderboard..."
  users = User.all
  users.each do |u|
    Path.all.each do |p|
      Leaderboard.reset_for_path_user(p, u)
    end
  end
end