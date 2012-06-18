class AddAvailableVotesToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :available_votes, :integer, :default => 0
  end
end
