class CreateCustomStylesTable < ActiveRecord::Migration
	def change
	  create_table :custom_styles do |t|
      t.integer :company_id
			t.boolean :is_active
			t.text :core_layout_styles
			t.text :add_on_styles
      t.timestamps
    end
	end
end
