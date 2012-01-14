class AddIsPublicToPaths < ActiveRecord::Migration
  def change
	add_column :paths, :is_public, :boolean
  end
end
