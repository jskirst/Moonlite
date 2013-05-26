task :calculate_path_averages => :environment do
  # ENV['PATH_AVERAGES'] = {}
  # Path.all.each do |path|
  #   cts = path.completed_tasks.where("answer_type in (?)", [Task::MULTIPLE, Task::EXACT])
  #   enrollments = path.enrollments.where(total_points: 0).count
  #   stats = {
  #     tasks_attempted: (cts.count / (enrollments == 0 ? 1 : enrollments)),
  #     percent_correct: (cts.where("status_id = ?", Answer::CORRECT).count.to_f / cts.count),
  #     correct_points: (cts.where("status_id = ?", Answer::CORRECT).average(:points_awarded).to_f)
  #   }
  #   PATH_AVERAGES[path.id] = stats
  # end
end