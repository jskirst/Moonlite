class AddLargeImageUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :large_image_url, :string
  end
end
