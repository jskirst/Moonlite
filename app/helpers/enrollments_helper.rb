module EnrollmentsHelper
  def extract_enrollment_details(enrollment)
    path = enrollment.path
    core = enrollment.completed_tasks.joins(:task)
      .joins("LEFT JOIN topics on topics.id=tasks.topic_id")
      .select("topics.*, tasks.*, completed_tasks.*")
      .where("tasks.path_id = ?", path.id)
      .where("tasks.answer_type in (?)", [Task::MULTIPLE, Task::EXACT]).to_a
    creative = enrollment.completed_tasks.joins(:task)
      .joins("LEFT JOIN submitted_answers on submitted_answers.id = completed_tasks.submitted_answer_id")
      .select("submitted_answers.*, tasks.*, completed_tasks.*")
      .where("tasks.path_id = ?", path.id)
      .where("tasks.answer_type in (?)", [Task::CREATIVE]).to_a
    tasks = enrollment.completed_tasks.joins(:task)
      .where("tasks.path_id = ?", path.id)
      .where("tasks.answer_type in (?)", [Task::CHECKIN]).to_a
    
    details = { 
      path: path,
      metascore_available: path.metascore_available?,
      name: path.name, 
      permalink: path.permalink, 
      core: core,
      creative: creative,
      tasks: tasks,
      performance: PerformanceStatistics.new(core),
      metascore: enrollment.metascore,
      metapercentile: enrollment.metapercentile
    }

    details[:is_difficult] = path.difficult?

    if details[:metascore] < 260
      details[:skill_level] = Enrollment.describe_skill_level(details[:metascore])
      details[:ms_for_graph] = 260
    elsif !details[:is_difficult] and details[:metascore] > 385
      details[:skill_level] = "Competent"
      details[:ms_for_graph] = 385
    else
      details[:skill_level] = Enrollment.describe_skill_level(details[:metascore])
      details[:ms_for_graph] = details[:metascore]
    end
    return details
  end
end