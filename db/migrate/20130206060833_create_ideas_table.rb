class CreateIdeasTable < ActiveRecord::Migration
  def change
    create_table :ideas do |t|
      t.integer :creator_id
      
      t.string  :title
      t.text    :description
      t.string  :status
      
      t.timestamps
    end
  end
end
