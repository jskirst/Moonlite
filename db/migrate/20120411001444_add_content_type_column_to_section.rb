class AddContentTypeColumnToSection < ActiveRecord::Migration
  def change
    add_column :sections, :content_type, :string
  end
end
