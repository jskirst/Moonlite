class AddStatusToCompletedTasks < ActiveRecord::Migration
  def self.up
	add_column :completed_tasks, :status_id, :integer, :default => 0
	remove_index :completed_tasks, [:user_id, :task_id]
  end

  def self.down
	remove_column :completed_tasks, :status_id
	add_index :completed_tasks, [:user_id, :task_id], :uniqueness => true
  end
end
