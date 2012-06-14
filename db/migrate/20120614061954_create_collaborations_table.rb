class CreateCollaborationsTable < ActiveRecord::Migration
  def change
    create_table :collaborations do |t|
      t.integer :path_id
      t.integer :user_id
      t.integer :granting_user_id
      
      t.timestamps
    end
  end
end
