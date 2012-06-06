class AddLoginAtAndLogoutAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :login_at, :timestamp
    add_column :users, :logout_at, :timestamp
  end
end
