class AddPointsAwardedToCompletedTasks < ActiveRecord::Migration
  def change
		add_column :completed_tasks, :points_awarded, :integer
  end
end
