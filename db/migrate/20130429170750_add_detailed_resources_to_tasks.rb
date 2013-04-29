class AddDetailedResourcesToTasks < ActiveRecord::Migration
  def change
    change_column :tasks, :resource, :text
    add_column :tasks, :resource_title, :text
  end
end
