class ChangePathDescriptionDefault < ActiveRecord::Migration
  def change
    change_column :paths, :description, :string, :default => ''
  end
end
