class AddParentIdToPaths < ActiveRecord::Migration
  def change
    add_column :paths, :parent_id, :integer
  end
end
