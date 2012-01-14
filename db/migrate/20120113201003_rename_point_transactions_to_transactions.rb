class RenamePointTransactionsToTransactions < ActiveRecord::Migration
  def change
	rename_table :point_transactions, :user_transactions
	add_column :user_transactions, :path_id, :integer
	rename_column :user_transactions, :points, :amount
	change_column :user_transactions, :amount, :float
  end
end
