class AddEnableNonlinearSectionsToPaths < ActiveRecord::Migration
  def change
		add_column :paths, :enable_nonlinear_sections, :boolean, :default => false
  end
end
