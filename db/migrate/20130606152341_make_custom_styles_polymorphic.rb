class MakeCustomStylesPolymorphic < ActiveRecord::Migration
  def change
    rename_column :custom_styles, :company_id, :owner_id
    add_column :custom_styles, :owner_type, :string 
  end
end
