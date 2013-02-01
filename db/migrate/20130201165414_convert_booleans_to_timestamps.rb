class ConvertBooleansToTimestamps < ActiveRecord::Migration
  def change
    add_column :enrollments, :contribution_unlocked_at, :datetime
    add_column :users, :locked_at, :datetime
    add_column :paths, :approved_at, :datetime
    add_column :paths, :published_at, :datetime
    add_column :paths, :public_at, :datetime
    add_column :sections, :published_at, :datetime
    add_column :task_issues, :resolved_at, :datetime
    add_column :tasks, :reviewed_at, :datetime
    add_column :tasks, :locked_at, :datetime
    add_column :user_events, :read_at, :datetime
    add_column :comments, :reviewed_at, :datetime
    add_column :comments, :locked_at, :datetime
    add_column :submitted_answers, :reviewed_at, :datetime
    add_column :submitted_answers, :locked_at, :datetime
  end
end
