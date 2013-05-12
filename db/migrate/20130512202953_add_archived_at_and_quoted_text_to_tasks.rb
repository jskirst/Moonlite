class AddArchivedAtAndQuotedTextToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :archived_at, :datetime
    add_column :tasks, :quoted_text, :text
  end
end
