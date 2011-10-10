class CreateCompletedTasks < ActiveRecord::Migration
  def self.up
    create_table :completed_tasks do |t|
      t.integer :user_id
      t.integer :task_id

      t.timestamps
    end
	add_index :completed_tasks, [:user_id, :task_id], :uniqueness => true
  end

  def self.down
    drop_table :completed_tasks
  end
end
