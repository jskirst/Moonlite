class AddCategoryTypeToPaths < ActiveRecord::Migration
  def change
    add_column :paths, :category_type, :integer, :default => 0
  end
end
