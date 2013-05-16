class AddMetascoreToEnrollments < ActiveRecord::Migration
  def change
    add_column :enrollments, :metascore, :integer, default: 0
    add_column :enrollments, :metapercentile, :integer, default: 0
  end
end
