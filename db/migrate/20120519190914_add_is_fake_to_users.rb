class AddIsFakeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_fake_user, :boolean, :default => false
  end
end
