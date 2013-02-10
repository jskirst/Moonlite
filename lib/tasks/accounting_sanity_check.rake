task :accounting_sanity_check => :environment do
  User.each do |user|
    unless user.earned_points == user.enrollments.sum(&:total_points)
      raise "User##{user.id} earned_points does not match sum of total_points"
    end
    
    user.enrollments.each do |e|
      e.total_points = e.
    end
  end
end