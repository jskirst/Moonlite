class EvaluationPath < ActiveRecord::Base
  CORE_LIMIT = 25
  CREATIVE_LIMIT = 4

  attr_accessible :evaluation_id,
    :path_id
  
  belongs_to :evaluation
  belongs_to :path

  before_create :select_tasks

  def select_tasks
    if path.group_id
      core_limit = 1000
      creative_limit = 1000
    else
      core_limit = CORE_LIMIT
      creative_limit = CREATIVE_LIMIT
    end

    ids = path.tasks.where(answer_type: Task::MULTIPLE)
      .first(core_limit)
      .collect(&:id)
    ids += path.tasks.where(answer_type: Task::CREATIVE, answer_sub_type: Task::TEXT)
      .first(creative_limit)
      .collect(&:id)

    self.task_ids = ids.join(",")
  end
end