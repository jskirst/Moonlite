class AddHighestRankAndLongestStreakToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :highest_rank, :integer, default: 0
    add_column :enrollments, :longest_streak, :integer, default: 0
  end
end
