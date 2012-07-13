class RecreateAchievementsAsPersonas < ActiveRecord::Migration
  def change
    rename_table :achievements, :personas
    rename_table :user_achievements, :user_personas
    rename_table :path_achievements, :path_personas
  end
end
