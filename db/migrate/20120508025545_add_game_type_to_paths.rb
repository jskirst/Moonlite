class AddGameTypeToPaths < ActiveRecord::Migration
  def change
		add_column :paths, :game_type, :string, :default => "basic"
  end
end
