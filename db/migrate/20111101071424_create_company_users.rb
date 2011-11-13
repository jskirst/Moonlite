class CreateCompanyUsers < ActiveRecord::Migration
	def self.up
		create_table :company_users do |t|
			t.string :email
			t.integer :user_id
			t.integer :company_id
			t.string :token1
			t.string :token2
			t.timestamps
		end
	end

	def self.down
		drop_table :company_users
	end
end
