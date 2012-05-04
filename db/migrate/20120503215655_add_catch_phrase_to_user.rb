class AddCatchPhraseToUser < ActiveRecord::Migration
  def change
		add_column :users, :catch_phrase, :string
  end
end
