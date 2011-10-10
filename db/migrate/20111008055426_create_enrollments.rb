class CreateEnrollments < ActiveRecord::Migration
  def self.up
    create_table :enrollments do |t|
      t.integer :user_id
      t.integer :path_id

      t.timestamps
    end
	add_index :enrollments, :user_id
	add_index :enrollments, :path_id
  end

  def self.down
    drop_table :enrollments
  end
end
