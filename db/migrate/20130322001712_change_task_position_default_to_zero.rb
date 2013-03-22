class ChangeTaskPositionDefaultToZero < ActiveRecord::Migration
  def change
    change_column :tasks, :position, :integer, default: 0
  end
end
