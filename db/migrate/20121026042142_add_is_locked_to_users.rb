class AddIsLockedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_locked, :boolean, default: false
  end
end
