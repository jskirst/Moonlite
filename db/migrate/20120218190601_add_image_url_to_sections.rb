class AddImageUrlToSections < ActiveRecord::Migration
  def change
    add_column :sections, :image_url, :string
  end
end
