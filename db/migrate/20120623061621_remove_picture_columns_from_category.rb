class RemovePictureColumnsFromCategory < ActiveRecord::Migration
  def change
    remove_column :categories, :category_pic_file_name
    remove_column :categories, :category_pic_content_type
    remove_column :categories, :category_pic_file_size
    remove_column :categories, :category_pic_updated_at
  end
end
