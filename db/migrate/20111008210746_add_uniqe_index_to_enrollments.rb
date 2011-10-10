class AddUniqeIndexToEnrollments < ActiveRecord::Migration
	def self.up
		add_index :enrollments, [:user_id, :path_id], :uniqueness => true
	end

	def self.down
		remove_index :enrollments, [:user_id, :path_id], :uniqueness => true
	end
end
