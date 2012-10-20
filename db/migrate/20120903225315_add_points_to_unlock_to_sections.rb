class AddPointsToUnlockToSections < ActiveRecord::Migration
  def change
    add_column :sections, :points_to_unlock, :integer, default: 0
  end
end
