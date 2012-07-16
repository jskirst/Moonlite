class MakeUserTransactionPolymorphic < ActiveRecord::Migration
  def change
    add_column :user_transactions, :owner_id, :integer
    add_column :user_transactions, :owner_type, :string
    
    add_index :user_transactions, [:owner_id, :owner_type, :user_id]
  end
end
