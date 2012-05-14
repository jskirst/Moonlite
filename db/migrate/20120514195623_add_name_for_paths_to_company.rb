class AddNameForPathsToCompany < ActiveRecord::Migration
  def change
		add_column :companies, :name_for_paths, :string, :default => "certification"
  end
end
