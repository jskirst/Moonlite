class CreateSubscriptionsTable < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :followed_id
      t.integer :follower_id
      
      t.timestamps
    end
    
    add_index :subscriptions, [:followed_id, :follower_id], unique: true
  end
end
