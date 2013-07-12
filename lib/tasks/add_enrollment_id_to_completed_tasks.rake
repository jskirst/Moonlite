task :add_enrollment_id_to_completed_tasks => :environment do
  tasks_by_path_id = {}
  Path.all.each do |path|
    tasks_by_path_id[path.id] = path.tasks.pluck(:id)
  end

  Enrollment.all.each do |enrollment|
    puts "Enrollment ##{enrollment.id}"
    cts = CompletedTask.where(user_id: enrollment.user_id)
      .where("task_id IN (?)", tasks_by_path_id[enrollment.path_id])
      .where("enrollment_id is ?", nil)
    
    puts "Updating #{cts.size}"
    cts.update_all("enrollment_id = #{enrollment.id}")
  end
end