class RemovingLimitsFromDescriptionAndInstructions < ActiveRecord::Migration
  def change
	change_column :paths, :description, :text, :limit => nil
	change_column :sections, :instructions, :text, :limit => nil
  end
end
