class AddPrivateAtToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :private_at, :timestamp
  end
end
