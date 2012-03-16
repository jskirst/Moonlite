class ChangePathDescriptionDefault < ActiveRecord::Migration
  def up
    change_column :paths, :description, :text, :default => ''
  end
  
  def down
    change_column :paths, :description, :text, :default => nil
  end
end
