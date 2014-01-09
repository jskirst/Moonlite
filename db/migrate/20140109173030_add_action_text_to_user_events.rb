class AddActionTextToUserEvents < ActiveRecord::Migration
  def change
    add_column :user_events, :action_text, :string
  end
end
