task :send_contribution_unlock_alerts => :environment do
  users = {}
  
  Enrollment.all.each do |e|
    if e.contribution_unlocked? && e.id < 687
      user = e.user
      path = e.path
      unless (path.tasks.where("creator_id = ?", user.id).count > 0) 
        if e.user.emails_today == 0
          begin
            count = users[user.id]
            puts count
            puts "Emails(#{user.id}): #{user.emails_today}"
            if count.to_i == 2
              puts "Skipping(#{user.id}) - email count > 1"
            else
              puts "Sending contribution unlock #{e.id}"
              users[user.id] = users[user.id].to_i + 1
              Mailer.contribution_unlocked(user.email, path).deliver
            end
          rescue
            puts "Contribution unlock rejected(#{user.id}). #{$!} #{e.id}"
          end
        else
          puts "Skipping(#{user.id}) - Already emailed today"
        end
      else
        puts "Skipping(#{user.id}) - already made #{e.id}"
      end
    else
      puts "Skipping#{e.user_id} - not unlocked #{e.id}"
    end
  end
end