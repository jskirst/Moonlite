class AddIsLockedToPath < ActiveRecord::Migration
  def change
		add_column :paths, :is_locked, :boolean, :default => false
  end
end
