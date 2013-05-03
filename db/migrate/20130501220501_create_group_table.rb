class CreateGroupTable < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.text :description
      t.text :image_url
      t.string :permalink
      t.string :website
      t.string :city
      t.string :state
      t.string :country
      t.timestamps
    end
    create_table :group_users do |t|
      t.integer :group_id
      t.integer :user_id
      t.timestamps  
     end
   end
end
