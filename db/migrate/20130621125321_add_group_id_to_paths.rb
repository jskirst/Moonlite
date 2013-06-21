class AddGroupIdToPaths < ActiveRecord::Migration
  def change
    add_column :paths, :group_id, :integer
  end
end
