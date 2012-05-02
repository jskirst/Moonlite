class RemoveOwnerIdFromTables < ActiveRecord::Migration
	def change
		remove_column :achievements, :owner_id
		remove_column :companies, :owner_id
		remove_column :company_users, :owner_id
		remove_column :completed_tasks, :owner_id
		remove_column :enrollments, :owner_id
		remove_column :info_resources, :owner_id
		remove_column :paths, :owner_id
		remove_column :rewards, :owner_id
		remove_column :sections, :owner_id
		remove_column :tasks, :owner_id
		remove_column :users, :owner_id
		remove_column :user_achievements, :owner_id
		remove_column :user_transactions, :owner_id
	end
end
