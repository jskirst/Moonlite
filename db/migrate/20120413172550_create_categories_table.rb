class CreateCategoriesTable < ActiveRecord::Migration
	def change
	  create_table :categories do |t|
      t.integer :company_id
			t.string :name
      t.timestamps
    end
	end
end
