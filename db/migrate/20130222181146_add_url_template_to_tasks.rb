class AddUrlTemplateToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :url_template, :string, default: Task::URL_TEMPLATES[Task::WILDCARD_URL]
    add_column :tasks, :url_type, :integer, default: 0
  end
end
