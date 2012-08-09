class AddCustomEmailFromToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :custom_email_from, :string
  end
end
