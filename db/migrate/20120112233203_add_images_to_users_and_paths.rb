class AddImagesToUsersAndPaths < ActiveRecord::Migration
  def change
	add_column :users, :image_url, :string
	add_column :paths, :image_url, :string
  end
end
