class RemoveCompanyFromEverything < ActiveRecord::Migration
  def change
    drop_table :categories
    drop_table :companies
    
    remove_column :paths, :company_id
    remove_column :paths, :category_id
    remove_column :personas, :company_id
    remove_column :user_roles, :company_id
    remove_column :users, :company_id
  end
end
