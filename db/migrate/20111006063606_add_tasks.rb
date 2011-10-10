class AddTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :question
      t.string :answer
      t.string :resource
      t.integer :rank
      t.integer :path_id

      t.timestamps
    end
	add_index :tasks, :path_id
  end

  def self.down
    drop_table :tasks
  end
end
