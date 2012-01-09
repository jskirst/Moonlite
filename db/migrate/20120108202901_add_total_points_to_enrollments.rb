class AddTotalPointsToEnrollments < ActiveRecord::Migration
  def change
	add_column :enrollments, :total_points, :integer
  end
end
