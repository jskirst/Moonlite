task :send_contribution_unlock_alerts => :environment do
  Enrollment.all.each do |e|
    if e.contribution_unlocked?
      user = e.user
      path = e.path
      unless path.tasks.where("creator_id = ?", user.id).count > 0
        Mailer.contribution_unlocked(user.email, path).deliver
      end
    end
  end
end