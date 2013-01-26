class AddIsReviewedToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :is_reviewed, :boolean, default: false
  end
end
