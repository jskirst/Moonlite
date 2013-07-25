class AddClosedToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :closed_at, :timestamp
    add_column :groups, :closed_reason, :text
  end
end
