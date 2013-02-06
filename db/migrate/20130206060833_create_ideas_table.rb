class CreateIdeasTable < ActiveRecord::Migration
  def change
    create_table :ideas do |t|
      t.integer :creator_id
      
      t.integer :owner_id
      t.string  :owner_type
      
      t.string  :title
      t.text    :description
      t.string  :status
      
      t.timestamps
    end
  end
end
