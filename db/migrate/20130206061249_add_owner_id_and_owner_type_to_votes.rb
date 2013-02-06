class AddOwnerIdAndOwnerTypeToVotes < ActiveRecord::Migration
  def change
    rename_column :votes, :submitted_answer_id, :owner_id
    add_column :votes, :owner_type, :string, default: "SubmittedAnswer"
    
    add_index :votes, [:owner_id, :owner_type, :user_id], unique: true
  end
end
