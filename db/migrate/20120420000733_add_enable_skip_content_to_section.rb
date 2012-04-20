class AddEnableSkipContentToSection < ActiveRecord::Migration
  def change
		add_column :sections, :enable_skip_content, :boolean, :default => false
  end
end
