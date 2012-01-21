class ChangePathIdToSectionId < ActiveRecord::Migration
  def change
	rename_column :tasks, :path_id, :section_id
  end
end
