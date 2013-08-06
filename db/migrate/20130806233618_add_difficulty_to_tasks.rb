class AddDifficultyToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :difficulty, :integer, default: 1
  end
end
