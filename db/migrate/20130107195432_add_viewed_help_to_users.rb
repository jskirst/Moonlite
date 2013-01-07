class AddViewedHelpToUsers < ActiveRecord::Migration
  def change
    add_column :users, :viewed_help, :text
  end
end
