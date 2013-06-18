class CreateEvaluationTable < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.string :title
      t.string :company
      t.string :link
      t.string :permalink
      t.integer :user_id
      t.timestamps
    end
    add_index :evaluations, :permalink, unique: true
    add_column :enrollments, :evaluation_id, :integer
    create_table :evaluation_paths do |t|
      t.integer :evaluation_id
      t.integer :path_id
      t.timestamps
    end
  end
end