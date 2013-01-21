class CreateTaskIssueTable < ActiveRecord::Migration
  def change
    create_table :task_issues do |t|
      t.integer :task_id
      t.integer :user_id
      t.integer :issue_type
      t.boolean :resolved, default: false
      
      t.timestamps
    end
  end
end
