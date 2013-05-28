class CreateTopicsTable < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.integer :path_id
      t.string  :name
      t.timestamps
    end

    add_column :tasks, :topic_id, :integer
  end
end
