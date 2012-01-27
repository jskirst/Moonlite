class AddCompanyAdminToUsers < ActiveRecord::Migration
  def change
	add_column :users, :company_admin, :boolean, :default => false
  end
end
