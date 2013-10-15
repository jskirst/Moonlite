class ChangeDifficultyToDecimal < ActiveRecord::Migration
  def change
    change_column :tasks, :difficulty, :decimal, default: 0.0
  end
end
