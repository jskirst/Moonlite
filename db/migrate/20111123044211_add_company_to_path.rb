class AddCompanyToPath < ActiveRecord::Migration
  def change
	add_column :paths, :company_id, :integer
  end
end
