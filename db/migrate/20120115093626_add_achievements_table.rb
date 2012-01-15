class AddAchievementsTable < ActiveRecord::Migration
  def change
   create_table :achievements do |t|
      t.string :name
      t.string :description
      t.string :criteria
      t.integer :points
      t.integer :path_id

      t.timestamps
    end
  end
end
