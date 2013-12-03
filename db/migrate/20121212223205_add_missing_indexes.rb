class AddMissingIndexes < ActiveRecord::Migration
  def up
    add_index :users, [:username], unique: true
    add_index :paths, [:permalink], unique: true
    add_index :answers, [:task_id]
    add_index :completed_tasks, [:user_id, :task_id]
    add_index :path_personas, [:path_id, :persona_id], unique: true
    add_index :sections, [:path_id]
    add_index :submitted_answers, [:task_id]
    add_index :user_auths, [:user_id]
    add_index :user_events, [:user_id]
    add_index :user_personas, [:user_id, :persona_id], unique: true
    add_index :votes, [:user_id]
  end
end
