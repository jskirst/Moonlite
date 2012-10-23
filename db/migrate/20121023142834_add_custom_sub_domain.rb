class AddCustomSubDomain < ActiveRecord::Migration
  def change
    add_column :companies, :custom_domain, :string
  end
end
