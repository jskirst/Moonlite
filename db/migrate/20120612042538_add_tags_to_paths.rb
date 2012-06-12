class AddTagsToPaths < ActiveRecord::Migration
  def change
    add_column :paths, :tags, :string
  end
end
