module EditorHelper
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
    
    content_tag(:span, task.desc(:difficulty), class: "label label-#{difficulty_class}")
  end
end