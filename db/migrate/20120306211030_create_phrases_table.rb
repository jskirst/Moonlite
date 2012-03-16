class CreatePhrasesTable < ActiveRecord::Migration
  def change
    create_table :phrases do |t|
      t.string :content
      t.timestamps
    end
    
    add_index :phrases, :content, :unique => true
  end
end
