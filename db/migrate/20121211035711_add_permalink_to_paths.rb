class AddPermalinkToPaths < ActiveRecord::Migration
  def change
    remove_column :paths, :game_type
    add_column :paths, :permalink, :string
  end
end
