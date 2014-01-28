class AddTaskIdsToEvaluationPaths < ActiveRecord::Migration
  def change
    add_column :evaluation_paths, :task_ids, :text
  end
end
