task :check_is_complete => :environment do
  User.includes(:enrollments).all.each do |u|
    u.enrollments.each do |e|
      e.update_attribute(:is_complete, true) if e.path.total_remaining_tasks(u) <= 0
    end
  end
end