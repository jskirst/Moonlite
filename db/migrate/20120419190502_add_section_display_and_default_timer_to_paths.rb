class AddSectionDisplayAndDefaultTimerToPaths < ActiveRecord::Migration
  def change
		add_column :paths, :enable_section_display, :boolean, :default => true
		add_column :paths, :default_timer, :integer, :default => 30
  end
end
