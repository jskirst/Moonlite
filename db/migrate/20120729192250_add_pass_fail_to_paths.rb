class AddPassFailToPaths < ActiveRecord::Migration
  def change
    add_column :paths, :passing_score, :integer
    add_column :paths, :enable_path_retakes, :boolean, default: false
    add_column :enrollments, :is_score_sent, :boolean, default: false
    add_column :enrollments, :is_passed, :boolean, default: false
    add_column :enrollments, :percentage_correct, :integer
  end
end
