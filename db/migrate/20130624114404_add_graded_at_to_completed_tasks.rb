class AddGradedAtToCompletedTasks < ActiveRecord::Migration
  def change
    add_column :completed_tasks, :graded_at, :timestamp
  end
end
