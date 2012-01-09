class AddEarnedPointsAndSpentPointsToUsers < ActiveRecord::Migration
  def change
	add_column :users, :earned_points, :integer, :default => 0
	add_column :users, :spent_points, :integer, :default => 0
	change_column :enrollments, :total_points, :integer, :default => 0
  end
end
