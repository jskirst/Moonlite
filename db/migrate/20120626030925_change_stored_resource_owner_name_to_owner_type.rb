class ChangeStoredResourceOwnerNameToOwnerType < ActiveRecord::Migration
  def change
    rename_column :stored_resources, :owner_name, :owner_type
  end
end
