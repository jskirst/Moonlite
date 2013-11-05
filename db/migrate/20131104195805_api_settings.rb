class ApiSettings < ActiveRecord::Migration
  def change
    add_column :groups, :api_enabled_at, :timestamp
    add_column :users, :private_at, :timestamp
  end
end
