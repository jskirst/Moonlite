task :update_streak_and_rank => :environment do
  Enrollment.all.each do |e|
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
    e.longest_streak = longest_streak
    e.highest_rank = e.rank unless e.highest_rank > e.rank
    e.save
  end
end