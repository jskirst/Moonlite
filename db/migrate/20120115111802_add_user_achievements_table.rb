class AddUserAchievementsTable < ActiveRecord::Migration
  def change
   create_table :user_achievements do |t|
      t.integer :achievement_id
      t.integer :user_id

      t.timestamps
    end
  end
end
