class ChangeCommentsToIsAttachable < ActiveRecord::Migration
  def change
    rename_column :comments, :task_id, :owner_id
    add_column :comments, :owner_type, :string
  end
end
