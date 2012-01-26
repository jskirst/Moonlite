class AddOwnerIdToAllTables < ActiveRecord::Migration
	def change
		add_column :achievements, :owner_id, :integer
		add_column :companies, :owner_id, :integer
		add_column :company_users, :owner_id, :integer
		add_column :completed_tasks, :owner_id, :integer
		add_column :enrollments, :owner_id, :integer
		add_column :info_resources, :owner_id, :integer
		add_column :paths, :owner_id, :integer
		add_column :rewards, :owner_id, :integer
		add_column :sections, :owner_id, :integer
		add_column :tasks, :owner_id, :integer
		add_column :users, :owner_id, :integer
		add_column :user_achievements, :owner_id, :integer
		add_column :user_transactions, :owner_id, :integer
	end
end
