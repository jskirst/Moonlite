class CreatePathUserRolesTable < ActiveRecord::Migration
  def change
		create_table :path_user_roles do |p|
			p.integer :user_role_id
			p.integer :path_id
			p.timestamps
		end
		add_index :path_user_roles, [:user_role_id, :path_id], :unique => true
	end
end
