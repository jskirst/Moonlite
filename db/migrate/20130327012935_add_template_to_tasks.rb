class AddTemplateToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :template, :text
  end
end
