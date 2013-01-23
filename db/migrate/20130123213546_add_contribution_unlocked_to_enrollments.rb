class AddContributionUnlockedToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :contribution_unlocked, :boolean, default: false
  end
end
