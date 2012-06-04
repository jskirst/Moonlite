class AddIsAnonymousToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_anonymous, :boolean, :default => false
    
    User.where("name = ? or name = ?", "beginner", "anonymous").each do |u|
      name = u.generate_username
      is_anonymous = true
      u.update_attributes(:name => u.generate_username, :is_anonymous => is_anonymous)
    end
  end
end
