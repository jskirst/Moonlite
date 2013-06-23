class AddDeletedAtToCompletedTask < ActiveRecord::Migration
  def change
    add_column :completed_tasks, :deleted_at, :timestamp
  end
end
