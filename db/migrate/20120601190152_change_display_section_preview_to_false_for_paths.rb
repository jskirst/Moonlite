class ChangeDisplaySectionPreviewToFalseForPaths < ActiveRecord::Migration
  def change
    change_column :paths, :enable_section_display, :boolean, :default => false
  end
end
