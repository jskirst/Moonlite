class AddDescriptionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :description, :string
    add_column :users, :education, :string
    add_column :users, :company_name, :string
    add_column :users, :title, :string
    add_column :users, :location, :string
    add_column :users, :link, :string
  end
end
