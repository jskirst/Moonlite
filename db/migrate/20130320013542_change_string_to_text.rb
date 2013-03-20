class ChangeStringToText < ActiveRecord::Migration
  def change
    change_column :visits, :request_url, :text
    change_column :comments, :content, :text
    change_column :stored_resources, :link, :text
    change_column :user_events, :content, :text
  end
end
