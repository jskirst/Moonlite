class AddPublishedAtToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :published_at, :timestamp
  end
end
