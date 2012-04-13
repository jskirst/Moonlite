class ChangeCategoryTypeToCategoryIdOnPaths < ActiveRecord::Migration
  def change
		rename_column :paths, :category_type, :category_id
	end
end
