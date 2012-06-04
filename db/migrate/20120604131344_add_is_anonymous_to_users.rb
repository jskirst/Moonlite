class AddIsAnonymousToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_anonymous, :boolean, :default => false
  end
end
