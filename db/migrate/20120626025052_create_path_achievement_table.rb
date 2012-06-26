class CreatePathAchievementTable < ActiveRecord::Migration
  def change
    create_table :path_achievements do |t|
      t.integer :path_id
      t.integer :achievement_id
    end
  end
end
