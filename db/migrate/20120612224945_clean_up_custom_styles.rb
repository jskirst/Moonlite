class CleanUpCustomStyles < ActiveRecord::Migration
  def change
    remove_column :custom_styles, :add_on_styles
    rename_column :custom_styles, :core_layout_styles, :styles
    remove_column :custom_styles, :is_active
    add_column :custom_styles, :mode, :integer, :default => 0
  end
end
