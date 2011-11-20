class CreateInfoResource < ActiveRecord::Migration
  def self.up
	create_table :info_resources do |t|
		t.string :description
		t.string :link
		t.integer :path_id
		
		t.timestamps
	end
	add_index :info_resources, :path_id
  end

  def self.down
	drop_table :info_resources
  end
end
