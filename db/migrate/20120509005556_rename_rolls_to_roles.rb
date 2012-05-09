class RenameRollsToRoles < ActiveRecord::Migration
  def change
		rename_table :user_rolls, :user_roles
		rename_column :users, :user_roll_id, :user_role_id
		rename_column :companies, :user_roll_id, :user_role_id
	end
end
