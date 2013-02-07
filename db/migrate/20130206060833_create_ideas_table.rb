class CreateIdeasTable < ActiveRecord::Migration
  def change
    create_table :ideas do |t|
      t.integer :creator_id
      
      t.string  :title
      t.text    :description
      t.string  :status
      
      t.integer :vote_count, default: 0
      
      t.timestamps
    end
  end
end
