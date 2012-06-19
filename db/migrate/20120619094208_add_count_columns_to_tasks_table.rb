class AddCountColumnsToTasksTable < ActiveRecord::Migration
  def change
    add_column :tasks, :count_answer1, :integer, :default => 0
    add_column :tasks, :count_answer2, :integer, :default => 0
    add_column :tasks, :count_answer3, :integer, :default => 0
    add_column :tasks, :count_answer4, :integer, :default => 0
  end
end
