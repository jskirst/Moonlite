class CreateNotificationSettingsTable < ActiveRecord::Migration
  def change
    create_table :notification_settings do |t|
      t.integer     :user_id
      
      t.boolean     :powers, default: true
      t.boolean     :weekly, default: true
      t.boolean     :interaction, default: true
      
      t.boolean     :inactive, default: false
      
      t.timestamps
    end
    
    add_index :notification_settings, [:user_id], uniqueness: true
  end
end
