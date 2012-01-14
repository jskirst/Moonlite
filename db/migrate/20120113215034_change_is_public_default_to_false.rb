class ChangeIsPublicDefaultToFalse < ActiveRecord::Migration
  def change
	change_column :paths, :is_public, :boolean, :default => false
  end
end
