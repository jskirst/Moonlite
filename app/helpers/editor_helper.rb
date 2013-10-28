module EditorHelper
  def completion_statistics_label(task)
    cts = task.completed_tasks
    total_count = cts.count
    total = total_count == 0 ? 1 : total_count
    correct = cts.where(status_id: Answer::CORRECT).count
    incorrect = cts.where(status_id: Answer::INCORRECT).count
    incomplete = cts.where(status_id: Answer::INCOMPLETE).count
    str = "#{total_count} Total / #{((correct.to_f/total)*100).round(0)}% Correct / #{((incorrect.to_f/total)*100).round(0)}% Incorrect / #{((incomplete.to_f/total)*100).round(0)}% Incomplete"
    content_tag(:p, content_tag(:span, str, class: "label"))
  end

  def difficulty_label(task)
    difficulty_class = case task.difficulty
    when Task::EASY
      "success"
    when Task::MEDIUM
      "warning"
    when Task::HARD
      "important"
    when Task::EXPERT
      "inverse"
    end
    
    content_tag(:span, task.describe_difficulty, class: "label label-#{difficulty_class}")
  end
end