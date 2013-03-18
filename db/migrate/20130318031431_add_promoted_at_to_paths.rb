class AddPromotedAtToPaths < ActiveRecord::Migration
  def change
    add_column :paths, :promoted_at, :datetime
  end
end
