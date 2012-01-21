class CreateTableSections < ActiveRecord::Migration
  def change
	create_table :sections do |t|
		t.integer :path_id
		t.string :name
		t.string :instructions
		t.integer :position
		t.timestamps
	end
  end
end
