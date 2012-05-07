class AddEnableRetakeToPaths < ActiveRecord::Migration
  def change
		add_column :paths, :enable_retakes, :boolean, :default => true
  end
end
