class CreateLeaderboards < ActiveRecord::Migration
  def change
    create_table :leaderboards do |t|
      t.integer :user_id
      t.integer :completed_tasks, :default => 0
      t.integer :score, :default => 0

      t.timestamps
    end
  end
end
