class AddIsLockedToPersonas < ActiveRecord::Migration
  def change
    add_column :personas, :is_locked, :boolean, default: true
  end
end
