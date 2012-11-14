class AddLinkAndIsReadToUserEvents < ActiveRecord::Migration
  def change
    add_column :user_events, :is_read, :boolean, default: false
    add_column :user_events, :link, :string
    add_column :user_events, :actioner_id, :integer
    remove_column :user_events, :path_id
    add_column :user_events, :image_link, :string
  end
end
