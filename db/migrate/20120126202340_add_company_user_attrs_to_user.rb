class AddCompanyUserAttrsToUser < ActiveRecord::Migration
  def change
	add_column :users, :signup_token, :string
	add_column :users, :company_id, :integer
  end
end
