class AddPurchasedPathIdToPaths < ActiveRecord::Migration
  def change
	add_column :paths, :purchased_path_id, :integer
  end
end
