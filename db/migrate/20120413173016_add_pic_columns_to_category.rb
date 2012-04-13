class AddPicColumnsToCategory < ActiveRecord::Migration
  def change
		add_column :categories, :category_pic_file_name,    :string
		add_column :categories, :category_pic_content_type, :string
    add_column :categories, :category_pic_file_size,    :integer
    add_column :categories, :category_pic_updated_at,   :datetime
  end
end
