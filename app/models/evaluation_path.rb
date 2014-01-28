class EvaluationPath < ActiveRecord::Base
  attr_accessible :evaluation_id,
    :path_id
  
  belongs_to :evaluation
  belongs_to :path

  before_create :select_tasks

  def select_tasks
    if path.group_id
      core_ids = core_tasks.pluck(:id)
      creative_ids = creative_tasks.pluck(:id)
    else
      core_ids = core_tasks_with_difficulty(Task::EXPERT, 2.0).limit(4).pluck(:id)
      core_ids += core_tasks_with_difficulty(Task::HARD, Task::EXPERT).limit(8 - core_ids.size).pluck(:id)
      core_ids += core_tasks_with_difficulty(Task::MEDIUM, Task::HARD).limit(14 - core_ids.size).pluck(:id)
      core_ids += core_tasks_with_difficulty(0, Task::MEDIUM).limit(20 - core_ids.size).pluck(:id)
      creative_ids = creative_tasks.limit(4).pluck(:id)
    end
    task_id_ary = (core_ids.to_a + creative_ids.to_a).sort
    self.task_ids = task_id_ary.join(",")
  end

  def tasks_with_difficulty(tasks, lower_bound, upper_bound)
    tasks.where("difficulty >= ? and difficulty < ?", lower_bound, upper_bound)
  end

  def core_tasks_with_difficulty(lower_bound, upper_bound)
    tasks_with_difficulty(core_tasks, lower_bound, upper_bound)
  end

  def core_tasks
    path.tasks.where(answer_type: Task::MULTIPLE).where.not(professional_at: nil)
  end

  def creative_tasks
    path.tasks.where(answer_type: Task::CREATIVE, answer_sub_type: Task::TEXT).where.not(professional_at: nil)
  end
end