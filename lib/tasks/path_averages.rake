task :calculate_path_averages => :environment do
  Path.all.each do |path|
    cts = path.completed_tasks.where("answer_type in (?)", [Task::MULTIPLE, Task::EXACT])
    enrollments = path.enrollments.where(total_points: 0).count
    path.tasks_attempted = (cts.count / (enrollments == 0 ? 1 : enrollments))
    path.tasks_attempted = 10 unless path.tasks_attempted > 0
    path.percent_correct = (cts.where("status_id = ?", Answer::CORRECT).count.to_f / cts.count)
    path.percent_correct = 0.5 unless path.percent_correct > 0
    path.correct_points = (cts.where("status_id = ?", Answer::CORRECT).average(:points_awarded).to_f)
    path.correct_points = 50 unless path.correct_points > 0
    path.save
  end
end