class CreateVotesTable < ActiveRecord::Migration
  def change
    create_table :votes do |t|
      t.integer :submitted_answer_id
      t.integer :user_id
      
      t.timestamps
    end
    
    add_index :votes, [:user_id, :submitted_answer_id], :unique => true
  end
end
