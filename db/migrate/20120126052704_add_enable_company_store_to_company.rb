class AddEnableCompanyStoreToCompany < ActiveRecord::Migration
  def change
	add_column :companies, :enable_company_store, :boolean, :default => true
  end
end
