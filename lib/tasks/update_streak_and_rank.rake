task :update_streak_and_rank => :environment do
  Enrollment.all.each do |e|
    streak = 0
    longest_streak = 0
    e.completed_tasks.order("completed_tasks.id ASC").each do |ct|
      unless ct.correct?
        longest_streak = streak if streak > longest_streak
        streak = 0
      else
        streak += 1
      end
    end
    e.longest_streak = longest_streak
    e.highest_rank = e.rank
    e.save
  end
end