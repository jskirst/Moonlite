class AddNewTableCompany < ActiveRecord::Migration
	def self.up
		create_table :companies do |c|
			c.string :name

			c.timestamps
		end
	end

	def self.down
		drop_table :companies
	end
end
