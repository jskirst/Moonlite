class ChangeAllStoredObjectsToStoredResource < ActiveRecord::Migration
  def change
    rename_table :info_resources, :stored_resources
    add_column :stored_resources, :owner_id, :integer
    add_column :stored_resources, :owner_name, :string
    
    add_index :stored_resources, [:owner_id, :owner_name], :uniquness => false
  end
end
