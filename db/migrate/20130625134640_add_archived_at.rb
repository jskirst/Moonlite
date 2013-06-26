class AddArchivedAt < ActiveRecord::Migration
  def change
    add_column :evaluation_enrollments, :archived_at, :timestamp
    add_column :evaluation_enrollments, :favorited_at, :timestamp
  end
end
