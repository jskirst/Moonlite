class AddPathIdToTasksTable < ActiveRecord::Migration
  def change
    add_column :tasks, :path_id, :integer
   
    Path.all.each do |path|
      tasks = path.tasks.update_all :path_id => path.id
    end
  end
end
