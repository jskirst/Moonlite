class AddIsAdminToCompanyUser < ActiveRecord::Migration
  def change
	add_column :company_users, :is_admin, :boolean
  end
end
