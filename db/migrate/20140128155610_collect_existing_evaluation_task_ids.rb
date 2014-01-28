class CollectExistingEvaluationTaskIds < ActiveRecord::Migration
  def change
    EvaluationPath.find_each do |ep|
      existing_task_ids = ep.collect_existing_task_ids
      if existing_task_ids.empty?
        ep.select_tasks
      else
        ep.task_ids = existing_task_ids.join(",")
      end
      ep.save!
    end
  end
end
