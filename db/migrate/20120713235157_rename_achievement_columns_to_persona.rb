class RenameAchievementColumnsToPersona < ActiveRecord::Migration
  def change
    rename_column :path_personas, :achievement_id, :persona_id
    rename_column :user_personas, :achievement_id, :persona_id
  end
end
