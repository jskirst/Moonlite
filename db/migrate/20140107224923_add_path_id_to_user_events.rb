class AddPathIdToUserEvents < ActiveRecord::Migration
  def change
    add_column :user_events, :path_id, :integer
  end
end
