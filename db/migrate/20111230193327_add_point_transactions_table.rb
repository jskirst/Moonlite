class AddPointTransactionsTable < ActiveRecord::Migration
  def up
	create_table :point_transactions do |t|
		t.integer :user_id
		t.integer :reward_id
		t.integer :task_id
		t.integer :points
		t.integer :status
		t.timestamps
	end
  end

  def down
	drop_table :point_transactions
  end
end
