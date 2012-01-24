class ChangeDescriptionAndInstructionsToText < ActiveRecord::Migration
  def change
	change_column :paths, :description, :text
	change_column :sections, :instructions, :text
  end
end
