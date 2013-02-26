class AddUrlTemplateToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :url_template, :string
    add_column :tasks, :url_type, :integer, default: 0
  end
end
