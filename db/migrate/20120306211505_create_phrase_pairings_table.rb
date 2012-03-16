class CreatePhrasePairingsTable < ActiveRecord::Migration
  def change
    create_table :phrase_pairings do |t|
      t.integer :phrase_id
      t.integer :paired_phrase_id
      t.integer :strength, :default => 0
      t.timestamps
    end
    
    add_index :phrase_pairings, :phrase_id
  end
end
