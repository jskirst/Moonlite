class AddTypeToInfoResource < ActiveRecord::Migration
  def change
    add_column :info_resources, :info_type, :string
  end
end
