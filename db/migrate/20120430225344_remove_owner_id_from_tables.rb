class RemoveOwnerIdFromTables < ActiveRecord::Migration
	def change
		remove_column :achievements, :owner_id, :integer
		remove_column :companies, :owner_id, :integer
		remove_column :company_users, :owner_id, :integer
		remove_column :completed_tasks, :owner_id, :integer
		remove_column :enrollments, :owner_id, :integer
		remove_column :info_resources, :owner_id, :integer
		remove_column :paths, :owner_id, :integer
		remove_column :rewards, :owner_id, :integer
		remove_column :sections, :owner_id, :integer
		remove_column :tasks, :owner_id, :integer
		remove_column :users, :owner_id, :integer
		remove_column :user_achievements, :owner_id, :integer
		remove_column :user_transactions, :owner_id, :integer
	end
end
