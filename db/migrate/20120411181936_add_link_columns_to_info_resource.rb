class AddLinkColumnsToInfoResource < ActiveRecord::Migration
  def change
		add_column :info_resources, :obj_file_name,    :string
		add_column :info_resources, :obj_content_type, :string
    add_column :info_resources, :obj_file_size,    :integer
    add_column :info_resources, :obj_updated_at,   :datetime
  end
end
