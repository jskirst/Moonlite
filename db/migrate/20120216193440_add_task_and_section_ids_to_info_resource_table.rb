class AddTaskAndSectionIdsToInfoResourceTable < ActiveRecord::Migration
  def change
    add_column :info_resources, :section_id, :integer
    add_column :info_resources, :task_id, :integer
  end
end
