class AddIsCompleteToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :is_complete, :boolean, :default => false
  end
end
