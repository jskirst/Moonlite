class AddTasksAttemptedAndPercentCorrectAndCorrectPointsToPaths < ActiveRecord::Migration
  def change
    add_column :paths, :tasks_attempted, :integer
    add_column :paths, :percent_correct, :float
    add_column :paths, :correct_points, :float
  end
end
