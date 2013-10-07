class AddEnableContentCreationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :content_creation_enabled_at, :datetime
    
    time = Time.now
    User.where("users.earned_points >= ?", 1500).update_all("content_creation_enabled_at = '#{time}'")
  end
end
