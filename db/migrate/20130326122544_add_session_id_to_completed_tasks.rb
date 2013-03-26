class AddSessionIdToCompletedTasks < ActiveRecord::Migration
  def change
    add_column :completed_tasks, :session_id, :integer
  end
end
