class CreateUserEventTable < ActiveRecord::Migration
	def change
	  create_table :user_events do |t|
      t.integer :user_id
			t.integer :path_id
			t.string :content
      t.timestamps
    end
	end
end
