class AddInputTypeToPaths < ActiveRecord::Migration
  def change
    add_column :paths, :input_type, :integer, default: 1
  end
end
