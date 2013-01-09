class AddCreatorIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :creator_id, :integer
    add_column :tasks, :is_locked, :boolean, default: false
  end
end
