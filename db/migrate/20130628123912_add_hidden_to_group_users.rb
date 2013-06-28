class AddHiddenToGroupUsers < ActiveRecord::Migration
  def change
    add_column :group_users, :hidden, :boolean, default: false
  end
end
