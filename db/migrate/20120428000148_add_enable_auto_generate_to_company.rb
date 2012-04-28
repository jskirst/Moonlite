class AddEnableAutoGenerateToCompany < ActiveRecord::Migration
  def change
		add_column :companies, :enable_auto_generate, :boolean, :default => false
  end
end
