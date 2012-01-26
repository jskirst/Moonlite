class AddPublishedPublicPurchaseableToPaths < ActiveRecord::Migration
  def change
	add_column :paths, :is_published, :boolean, :default => false
	add_column :paths, :is_purchaseable, :boolean, :default => false
  end
end
