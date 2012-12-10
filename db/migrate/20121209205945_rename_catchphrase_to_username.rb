class RenameCatchphraseToUsername < ActiveRecord::Migration
  def change
    rename_column :users, :catch_phrase, :username
  end
end
