class StartOver < ActiveRecord::Migration
	def self.up
		drop_table :microposts
		
		create_table :modules do |t|
			t.string :name
			t.string :description
			t.integer :user_id
			t.timestamps
		end
		add_index :modules, :user_id
	end

	def self.down
		#no going back
	end
end
