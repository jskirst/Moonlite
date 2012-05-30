class AddIsTestUserToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_test_user, :boolean, :default => false
  end
end
